# Runbook: `daily_order_ingest` Pipeline Failures

**Pipeline:** `daily_order_ingest` — nightly ingest of completed orders from the order management system (OMS) into the warehouse
**Schedule:** `0 1 * * *` (01:00 daily)
**SLA:** 60 minutes
**Owner:** data-engineering
**Alert channel:** `data-engineering-alerts` (SLA breaches also page `data-management-leads`)

This runbook covers three known failure modes:

- **A.** `validate_orders` fails on `no_null_customer_id`
- **B.** `validate_orders` fails on `row_count_threshold` (bank holidays)
- **C.** `refresh_sales_summary` times out under heavy query load

---

## 1. Trigger

Activate this runbook when any of the following fires in `data-engineering-alerts`:

- `data_quality` step `validate_orders` reports failure on check `no_null_customer_id`, `row_count_threshold`, or `status_in_allowed_values`
- `transform` step `refresh_sales_summary` reports failure or timeout
- An SLA breach alert fires for `daily_order_ingest` (i.e., the pipeline has not completed within 60 minutes of its 01:00 start)

Note the exact `step_id` and error message from the alert before proceeding — the remediation path differs by which check failed.

---

## 2. Pre-checks

Before taking any remediation action, confirm the following. Do this even if the fix seems obvious — misdiagnosing A vs. B vs. C leads to the wrong remediation.

1. **Identify which step failed and why.** Pull the orchestrator run log for the specific `step_id` (`extract_orders`, `extract_order_items`, `validate_orders`, `load_orders`, `load_order_items`, or `refresh_sales_summary`) for this run's timestamp. Confirm the exact check name and failure message, not just "validate_orders failed."
2. **Check today's date against a holiday calendar** (UK bank holidays, since this is the relevant calendar for order volume dips) — this determines whether a row-count failure is expected (Failure Mode B) or anomalous.
3. **Check `staging.orders_raw` row count directly:**
   ```sql
   SELECT COUNT(*) FROM staging.orders_raw;
   ```
   Compare against the `min_rows: 100` threshold and against the same weekday last week to gauge whether the drop is holiday-sized or something worse (e.g., an upstream extraction failure).
4. **Check for null `customer_id` rows and their proportion:**
   ```sql
   SELECT COUNT(*) AS null_customer_rows,
          (SELECT COUNT(*) FROM staging.orders_raw) AS total_rows
   FROM staging.orders_raw
   WHERE customer_id IS NULL;
   ```
   A handful of nulls out of thousands of rows points to sporadic upstream data quality issues (Failure Mode A). A large proportion suggests a broader OMS extraction or schema problem — treat that as **out of scope for this runbook** and escalate immediately (see Section 5).
5. **Check whether `load_orders` and `load_order_items` completed before `refresh_sales_summary` failed.** Because `refresh_sales_summary`'s `on_failure` is `alert_and_continue`, the pipeline may show as "complete with warnings" rather than fully failed — confirm whether orders/order_items data is actually in `warehouse.orders` / `warehouse.order_items` regardless of the summary step's outcome.
6. **Check current load on `warehouse.orders`** (active sessions/blocking queries) if `refresh_sales_summary` is the failing step — this determines whether Failure Mode C is in play.
   ```sql
   -- example for SQL Server; adapt to your platform
   SELECT * FROM sys.dm_exec_requests WHERE blocking_session_id <> 0;
   ```

---

## 3. Step-by-step procedure

### Failure Mode A — `no_null_customer_id` fails (dropped/incomplete OMS records)

1. Re-run the null check from Pre-check 4 to get the exact count and list of affected `order_id`s:
   ```sql
   SELECT order_id, updated_at
   FROM staging.orders_raw
   WHERE customer_id IS NULL;
   ```
2. Confirm this is a small, isolated set of rows (consistent with known upstream incompleteness) rather than a mass failure.
3. Exclude the affected rows from `staging.orders_raw` so the rest of the batch can proceed:
   ```sql
   DELETE FROM staging.orders_raw WHERE customer_id IS NULL;
   ```
4. Re-run `validate_orders` manually via the orchestrator (do not skip validation — this check exists to protect `warehouse.orders` referential integrity).
5. Once `validate_orders` passes, resume the pipeline from `load_orders` onward.
6. Log the excluded `order_id`s in the incident ticket and flag them to the OMS team as records to backfill/correct upstream — they are currently missing from the warehouse and need to be re-ingested once fixed at the source.

### Failure Mode B — `row_count_threshold` fails on a bank holiday

1. Confirm via Pre-check 2 that today (or the run's target date) is a UK bank holiday, or immediately follows one where a volume dip is expected.
2. Confirm the row count from Pre-check 3 is low but non-zero and roughly consistent with prior holiday-period volumes (not a hard zero, which would instead suggest `extract_orders` silently returned nothing — check that step's row count too).
3. If the drop is holiday-consistent, manually override the failed check and resume the pipeline from `load_orders` via the orchestrator's "resume from step" function, rather than editing the threshold value in the config.
4. Do **not** permanently lower `min_rows` in `03_pipeline_config.json` to work around this — that would weaken the check for genuine extraction failures on non-holiday days. If holiday false-positives are frequent enough to be worth fixing properly, raise it as a backlog item (e.g., a holiday-aware threshold) rather than patching it during an incident.

### Failure Mode C — `refresh_sales_summary` times out under load

1. Confirm from Pre-check 5 that `load_orders` and `load_order_items` completed successfully — if so, the core order data is already safely in the warehouse and this is purely a downstream reporting issue, not a data-loss risk.
2. Confirm from Pre-check 6 whether there's active contention on `warehouse.orders` (long-running reports, concurrent ETL, ad hoc queries).
3. If contention is present, wait and retry `EXEC warehouse.usp_refresh_sales_summary` manually once the conflicting query finishes, rather than retrying repeatedly against the same lock.
4. If no obvious contention is found but the procedure still times out, run it manually outside the orchestrator with an extended timeout to get a completion time reading:
   ```sql
   EXEC warehouse.usp_refresh_sales_summary;
   ```
5. Once the procedure completes successfully, mark the step as resolved in the orchestrator so downstream SLA tracking reflects the true completion time.
6. If it consistently needs longer than the orchestrator's timeout allows, log this as a capacity/performance issue for follow-up (e.g., procedure optimization or a longer timeout allowance) rather than re-running it as a one-off fix each time.

---

## 4. Rollback

Only roll back if a remediation step above has caused incorrect or duplicate data in the warehouse.

1. **If rows were incorrectly deleted from `staging.orders_raw` (Failure Mode A) and this turns out to have been wrong** (e.g., the "incomplete" rows were actually valid): staging tables are transient and rebuilt each run, so no rollback is needed there — instead, re-run `extract_orders` for the affected time window to repopulate them, then proceed through validation again.
2. **If `load_orders` / `load_order_items` ran twice or with bad data reaching `warehouse.orders` / `warehouse.order_items`:** both loads use `upsert` on `merge_key` (`order_id` / `item_id`), so re-running with corrected staging data will overwrite bad rows safely — you do not need to manually delete from the warehouse tables first. Only perform a manual delete if specific `order_id`s must be removed entirely (e.g., rows that should never have been loaded):
   ```sql
   DELETE FROM warehouse.orders WHERE order_id IN (<affected ids>);
   DELETE FROM warehouse.order_items WHERE order_id IN (<affected ids>);
   ```
   Then re-run the load steps from clean staging data.
3. **If `refresh_sales_summary` produced a bad summary** (e.g., ran against partial data): re-run `EXEC warehouse.usp_refresh_sales_summary` once `warehouse.orders`/`warehouse.order_items` are confirmed correct — the procedure is a refresh, not an incremental append, so re-running it against correct source data self-corrects the summary.
4. **If you manually changed the pipeline config (e.g., threshold values) during the incident:** revert `03_pipeline_config.json` to its prior version before closing the incident — no threshold or config changes from this runbook should persist past the incident unless explicitly approved as a permanent change (see Failure Mode B, step 4).

---

## 5. Escalation path

Escalate immediately, rather than continuing to attempt remediation, if:

- **Null `customer_id` rows are a large proportion of the batch** (not a handful) — this suggests an OMS extraction or schema problem, not sporadic bad records. Escalate to the OMS system owner and post in `data-engineering-alerts`.
- **Row count is at or near zero on a non-holiday day** — this suggests `extract_orders` is silently failing rather than returning a genuinely low-volume day. Escalate to the on-call data engineering lead.
- **`refresh_sales_summary` continues to time out after a contention-free retry**, or contention itself cannot be resolved (e.g., another team's long-running job cannot be killed without their sign-off) — escalate to the data engineering lead and, if a warehouse-wide performance issue is suspected, to the DBA/platform team.
- **The pipeline has bre­ached its 60-minute SLA** regardless of which step is at fault — this triggers `data-management-leads` automatically per the alert config, but confirm they've been notified and give them a status update directly.
- **You are unsure whether excluding/deleting rows is safe** (Failure Modes A or rollback step 2) — do not guess; confirm with the data engineering lead before deleting anything from `staging` or `warehouse` tables.
- **Any step outside the three known failure modes fails** (e.g., `extract_orders`, `extract_order_items`, or an unrecognized `validate_orders` check) — this runbook doesn't cover it; escalate to the pipeline owner/on-call lead rather than improvising.

**Contacts:**
- First line: `data-engineering-alerts` channel — post the `step_id`, error message, and pre-check findings from Section 2
- Second line: on-call data engineering lead (page if no response within 15 minutes on an SLA-breaching incident)
- Third line: DBA/platform team, for warehouse-level contention or performance issues (Failure Mode C only)
