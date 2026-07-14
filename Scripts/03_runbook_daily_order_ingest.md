# Operational Runbook: `daily_order_ingest` Pipeline

**Pipeline:** `daily_order_ingest`
**Owner team:** data-engineering
**Schedule:** Nightly at 01:00 (cron: `0 1 * * *`)
**SLA:** 60 minutes (must complete by 02:00)
**Dependency:** `customer_dim_refresh` must succeed before this pipeline runs
**Last updated:** 2026-06-27

---

## Known Failure Modes Covered

| ID | Failure | Failing Step |
|----|---------|--------------|
| FM-1 | Upstream sends incomplete records; `customer_id` nulls fail validation | `validate_orders` |
| FM-2 | Order volume drops below 100 on bank holidays; row count check fails | `validate_orders` |
| FM-3 | `usp_refresh_sales_summary` times out under heavy query load | `refresh_sales_summary` |

---

## 1. Trigger

Activate this runbook when **any** of the following are true:

1. An alert fires to the `data-engineering-alerts` channel citing `daily_order_ingest`.
2. A downstream consumer reports missing or stale orders data in `warehouse.orders` or `warehouse.order_items`.
3. It is past 02:00 and the pipeline has not completed (SLA breach — `data-management-leads` will also be alerted).
4. You are asked to investigate a failure in any step of this pipeline.

---

## 2. Pre-Checks

Before taking any remedial action, establish the current state. Work through these in order.

1. **Confirm the dependency completed.** Verify that the `customer_dim_refresh` pipeline succeeded before `daily_order_ingest` started. Check your pipeline orchestrator's run log (e.g., Airflow DAG runs UI, or equivalent). If `customer_dim_refresh` failed, that is a separate incident — do not proceed with this runbook until it is resolved.

2. **Identify the failing step.** In the orchestrator run log, find today's run of `daily_order_ingest` and note which step is in a `FAILED` or `RUNNING` (hung) state: `extract_orders`, `extract_order_items`, `validate_orders`, `load_orders`, `load_order_items`, or `refresh_sales_summary`.

3. **Check staging table row counts.** Run the following to understand what data reached staging:

   ```sql
   SELECT COUNT(*) AS order_count   FROM staging.orders_raw;
   SELECT COUNT(*) AS item_count    FROM staging.order_items_raw;
   ```

   Note the counts. Zero rows in `staging.orders_raw` points to an extract failure. Low but non-zero row counts point to FM-2 (bank holiday). A plausible row count with failures points to FM-1 or a load issue.

4. **Check for null `customer_id` records:**

   ```sql
   SELECT COUNT(*) AS null_customer_ids
   FROM staging.orders_raw
   WHERE customer_id IS NULL;
   ```

   Any non-zero result confirms FM-1 is active.

5. **Check today's date against the bank holiday calendar.** If today is a recognised bank holiday and `staging.orders_raw` has a low but plausible row count (e.g., 20–80 rows), FM-2 is the likely cause.

6. **Check `refresh_sales_summary` separately.** If the earlier steps completed and only `refresh_sales_summary` failed or is still running after 20+ minutes, FM-3 (timeout under load) is the likely cause. Query the database's active session list:

   ```sql
   -- SQL Server example
   SELECT session_id, status, wait_type, wait_time, sql_text = SUBSTRING(st.text, 1, 200)
   FROM sys.dm_exec_requests r
   CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
   WHERE st.text LIKE '%usp_refresh_sales_summary%';
   ```

7. **Do not modify any warehouse tables yet.** Staging tables are safe to query; warehouse tables should only be touched as part of the procedures below.

---

## 3. Step-by-Step Procedures

Identify your failure mode from the pre-checks above, then follow the matching procedure. If more than one is active, resolve FM-1 before FM-2, and both before FM-3.

---

### Procedure A — FM-1: Null `customer_id` Records

**Situation:** `validate_orders` aborted because one or more rows in `staging.orders_raw` have a null `customer_id`. The pipeline stops here; no data is loaded to the warehouse.

1. Quantify the bad rows:

   ```sql
   SELECT COUNT(*)                          AS total_rows,
          SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_rows,
          MIN(updated_at)                   AS earliest_updated,
          MAX(updated_at)                   AS latest_updated
   FROM staging.orders_raw;
   ```

2. Inspect a sample of the affected records to understand which orders are involved:

   ```sql
   SELECT order_id, status, updated_at, created_at
   FROM staging.orders_raw
   WHERE customer_id IS NULL
   ORDER BY updated_at DESC;
   ```

3. **Contact the upstream system owner** (order management system team) with the `order_id` list and `updated_at` range. Ask them to confirm whether the missing `customer_id` values are a data issue on their side or expected (e.g., guest orders).

4. While waiting for their response, assess impact:

   ```sql
   -- Are any of these null-customer orders in a critical status?
   SELECT status, COUNT(*) AS cnt
   FROM staging.orders_raw
   WHERE customer_id IS NULL
   GROUP BY status;
   ```

5. **If upstream confirms these are bad records that will be corrected and re-sent:** Delete only the bad rows from staging, then re-trigger the pipeline from `validate_orders` (do not re-extract, as that would overwrite the clean rows already in staging).

   ```sql
   DELETE FROM staging.orders_raw WHERE customer_id IS NULL;
   -- Confirm clean:
   SELECT COUNT(*) FROM staging.orders_raw WHERE customer_id IS NULL;
   ```

   Then re-trigger from `validate_orders` in the orchestrator.

6. **If upstream confirms these are legitimate orders without customer IDs (e.g., guest checkouts):** This is a schema/business logic issue. Do **not** load null `customer_id` rows to the warehouse without explicit sign-off from the data-engineering lead. Escalate per Section 5.

7. **If upstream cannot be reached within 30 minutes of the SLA breach:** Escalate per Section 5. Do not load data with known quality failures.

---

### Procedure B — FM-2: Row Count Below Threshold on Bank Holiday

**Situation:** `validate_orders` aborted because `staging.orders_raw` has fewer than 100 rows. Today is a bank holiday and low order volume is expected.

1. Confirm the actual row count:

   ```sql
   SELECT COUNT(*) AS row_count FROM staging.orders_raw;
   ```

2. Compare to the same day last year (or the most recent equivalent bank holiday) to verify the low volume is consistent with historical patterns:

   ```sql
   -- Adjust the date range to match your warehouse's historical data retention
   SELECT CAST(created_at AS DATE) AS order_date, COUNT(*) AS order_count
   FROM warehouse.orders
   WHERE CAST(created_at AS DATE) IN (
       '2025-12-25', '2025-01-01'   -- replace with relevant prior bank holidays
   )
   GROUP BY CAST(created_at AS DATE)
   ORDER BY order_date;
   ```

3. If the current count is in the same range as prior bank holidays (and greater than zero), the data is valid and the check is a false positive.

4. **Temporarily override the row count check.** In the pipeline config (`03_pipeline_config.json`), the `row_count_threshold` check has `min_rows: 100`. To proceed, you have two options — choose based on your team's agreed process:

   - **Option 1 (preferred) — Skip the check for this run only:** If your orchestrator supports marking individual check steps as skipped/bypassed, bypass `validate_orders → row_count_threshold` only, leaving the other checks active (`no_null_customer_id`, `status_in_allowed_values`). Proceed to step 5.

   - **Option 2 — Manual load:** Run the load steps directly if the orchestrator does not support partial bypass:

     ```sql
     -- Confirm no null customer IDs before proceeding (run check manually)
     SELECT COUNT(*) FROM staging.orders_raw WHERE customer_id IS NULL;
     -- Confirm statuses are all valid
     SELECT DISTINCT status FROM staging.orders_raw
     WHERE status NOT IN ('Completed', 'Shipped', 'Processing', 'Cancelled');
     -- Both must return 0 rows before continuing
     ```

     If clean, proceed. The load steps use upsert logic and are safe to run manually — see sub-steps below.

5. **Run or re-trigger the load steps.** The upsert merge keys are `order_id` for orders and `item_id` for order items. These are idempotent — re-running will not duplicate data.

   If triggering manually:

   ```sql
   -- Equivalent of load_orders step (adapt to your warehouse's upsert syntax)
   MERGE warehouse.orders AS tgt
   USING staging.orders_raw AS src
   ON tgt.order_id = src.order_id
   WHEN MATCHED THEN UPDATE SET /* all columns */
   WHEN NOT MATCHED THEN INSERT /* all columns */;

   MERGE warehouse.order_items AS tgt
   USING staging.order_items_raw AS src
   ON tgt.item_id = src.item_id
   WHEN MATCHED THEN UPDATE SET /* all columns */
   WHEN NOT MATCHED THEN INSERT /* all columns */;
   ```

6. After load, run `refresh_sales_summary` (see Procedure C, step 1 onwards, if it subsequently times out; otherwise trigger normally).

7. **Log this exception.** Note the date, row count, and the override action taken in your team's incident log. Follow up with the data-engineering lead to discuss adding a bank holiday calendar check to the pipeline config so this does not require manual intervention in future.

---

### Procedure C — FM-3: `refresh_sales_summary` Timeout

**Situation:** Steps `extract_orders` through `load_order_items` completed successfully. `refresh_sales_summary` failed or is hanging. The pipeline config sets `on_failure: alert_and_continue` for this step, meaning the pipeline may have marked itself complete despite the failure — verify in the orchestrator.

1. Check whether the stored procedure is still actively running (use the query from Pre-check step 6). If it is running, note the `session_id`.

2. **Do not kill the session immediately.** First check how long it has been running:

   ```sql
   SELECT session_id, start_time, DATEDIFF(MINUTE, start_time, GETDATE()) AS runtime_minutes
   FROM sys.dm_exec_requests r
   WHERE session_id = <session_id_from_above>;
   ```

   If it has been running for fewer than 10 minutes, wait and re-check in 5 minutes — it may complete on its own.

3. If it has been running for 10+ minutes, identify what it is waiting on:

   ```sql
   SELECT wait_type, wait_time, blocking_session_id
   FROM sys.dm_exec_requests
   WHERE session_id = <session_id>;
   ```

   - If `blocking_session_id` is non-zero, there is a lock conflict. Note the blocking session before taking action.
   - Common wait types at this stage: `LCK_M_S` (shared lock wait), `PAGEIOLATCH_SH` (I/O under heavy read load).

4. **Check for heavy concurrent query load on `warehouse.orders`:**

   ```sql
   SELECT TOP 10 r.session_id, r.status, r.wait_type, r.wait_time,
          SUBSTRING(st.text, 1, 300) AS sql_text
   FROM sys.dm_exec_requests r
   CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
   WHERE r.session_id <> @@SPID
   ORDER BY r.wait_time DESC;
   ```

   If multiple sessions are hammering `warehouse.orders`, the sales summary refresh is competing for resources. Coordinate with the team to identify and defer any ad-hoc heavy queries before retrying.

5. If the session is hung with no prospect of completing, kill it:

   ```sql
   KILL <session_id>;
   ```

6. Wait 2 minutes for the rollback to complete, then verify the session is gone:

   ```sql
   SELECT session_id FROM sys.dm_exec_requests WHERE session_id = <session_id>;
   -- Should return 0 rows
   ```

7. Retry the stored procedure directly:

   ```sql
   EXEC warehouse.usp_refresh_sales_summary;
   ```

   Monitor the runtime. If it completes within 5 minutes, the issue was transient load.

8. If it times out again, **do not retry a third time** — escalate per Section 5. The sales summary is stale but `warehouse.orders` and `warehouse.order_items` are current; downstream consumers should be notified that the summary will be delayed.

9. Once `usp_refresh_sales_summary` completes successfully (either now or after escalation resolves the load issue), mark the pipeline run as succeeded in the orchestrator if it did not do so automatically.

---

## 4. Rollback

Use these steps if an action taken during the procedures above made things worse, or if you need to undo a partial load.

### Rollback a bad load to `warehouse.orders` or `warehouse.order_items`

The load steps use `upsert` (merge on `order_id` / `item_id`). There is no automatic rollback. To undo:

1. Identify the affected `order_id` range from `staging.orders_raw`:

   ```sql
   SELECT MIN(order_id) AS min_id, MAX(order_id) AS max_id,
          MIN(updated_at) AS earliest, MAX(updated_at) AS latest
   FROM staging.orders_raw;
   ```

2. Determine whether the upsert inserted new rows or updated existing ones. Check the warehouse for rows with `updated_at` timestamps matching today's pipeline run window (01:00–02:00):

   ```sql
   SELECT COUNT(*) AS rows_touched
   FROM warehouse.orders
   WHERE updated_at >= DATEADD(HOUR, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME))
     AND updated_at <  DATEADD(HOUR, 2, CAST(CAST(GETDATE() AS DATE) AS DATETIME));
   ```

3. **For newly inserted rows** (orders that did not exist in the warehouse before today's run): Delete them from `warehouse.orders` and their corresponding items from `warehouse.order_items`, using the `order_id` list from staging.

   ```sql
   -- Only do this after confirming these order_ids did not exist in the warehouse before today
   DELETE wi FROM warehouse.order_items wi
   WHERE wi.order_id IN (SELECT order_id FROM staging.orders_raw WHERE customer_id IS NULL);

   DELETE wo FROM warehouse.orders wo
   WHERE wo.order_id IN (SELECT order_id FROM staging.orders_raw WHERE customer_id IS NULL);
   ```

4. **For updated rows** (orders that existed and were overwritten): Restore from your warehouse backup or snapshot. Consult your DBA for the point-in-time restore procedure for `warehouse.orders`. Do not attempt to reconstruct values from staging.

5. After any rollback, clear staging:

   ```sql
   TRUNCATE TABLE staging.orders_raw;
   TRUNCATE TABLE staging.order_items_raw;
   ```

6. Re-trigger the full pipeline from `extract_orders` only after the underlying issue is resolved.

### Rollback a stale `usp_refresh_sales_summary`

This stored procedure refreshes a summary — it does not write source data. If it produced incorrect output, simply re-execute it after the underlying issue is resolved:

```sql
EXEC warehouse.usp_refresh_sales_summary;
```

There is no other rollback needed for this step.

---

## 5. Escalation Path

| Condition | Action | Contact |
|-----------|--------|---------|
| Upstream system is sending null `customer_id` and cannot be reached within 30 minutes | Page on-call data-engineering lead | `data-engineering-alerts` channel → tag `@de-oncall` |
| Row count anomaly is not explained by a bank holiday (volume is unexpectedly low on a normal working day) | Do not override the check. Escalate immediately | `data-engineering-alerts` → `@de-oncall` |
| `usp_refresh_sales_summary` times out twice in a row | Database performance issue beyond pipeline scope. Engage DBA | `data-engineering-alerts` → DBA on-call |
| SLA breach (pipeline not complete by 02:00) | Notify both alerts channels | `data-engineering-alerts` + `data-management-leads` (auto-alerted per config, but confirm receipt) |
| Any warehouse table has been modified and you are uncertain whether the state is correct | Stop all further actions and escalate | `@de-oncall` immediately |
| Escalation to the on-call DE lead has not resolved the issue within 30 minutes | Escalate to data-engineering manager | Obtain contact from your team directory |

When escalating, include:

- Pipeline run ID / execution timestamp from the orchestrator
- Which step failed
- Output of the relevant pre-check queries (row counts, null counts, session state)
- What actions you have already taken
- Current state of staging and warehouse tables
