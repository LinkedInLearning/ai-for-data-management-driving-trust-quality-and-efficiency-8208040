# Course Assets — AI for Data Management

All assets follow LinkedIn Learning data guidelines:
- No product brand names (use "Model X", "Type A", etc.)
- No vendor names (use "Vendor A", "Vendor B", etc.)
- No real store/platform names
- Generic regions (North, South, East, West, Central)

---

## Theme

A generic distribution and fulfilment company. They have products across several categories (Storage, Electronics, Furniture, Accessories, Infrastructure), sell to customers in four segments (Enterprise, SMB, Government, Education), and run a small set of data pipelines to keep the warehouse in sync with the order management system.

This single scenario threads through all five chapters — you explore the schema in Ch1, write queries against it in Ch2, document it in Ch3, diagnose pipeline failures in Ch4, and discuss governance risks around it in Ch5.

---

## Folder structure

```
Database/   — schema DDL, seed data CSVs, and the PowerShell load script
Scripts/    — SQL scripts, config files, demo data, and reference docs used in video demos
```

---

## Database/

### Core schema and data

| File | Description | Used in |
|------|-------------|---------|
| `schema.sql` | DDL for all 10 tables (SQL Server) | Ch1, Ch2, Ch3 |
| `New-SampleDatabase.ps1` | PowerShell script (dbatools) to create the database and load all CSVs into SQL Server | Ch1 setup |
| `warehouses.csv` | 5 warehouses by region | Ch1, Ch4 |
| `suppliers.csv` | 5 suppliers (Vendor A–E), domestic + international | Ch1 |
| `products.csv` | 15 products, generic names (Model A/B/X/Y, Type A/B) | Ch1, Ch2 |
| `customers.csv` | 25 customers, 4 segments, 5 regions | Ch1, Ch2 |
| `orders.csv` | 60 orders, 2024, mixed statuses (TINYINT: 1=Processing, 2=Shipped, 3=Completed, 4=Cancelled) | Ch2, Ch4 |
| `order_items.csv` | Line items for all orders | Ch2 |
| `inventory.csv` | Stock levels per product per warehouse | Ch1, Ch4 |
| `pipeline_runs.csv` | 50 pipeline run records with injected failures and real error messages | Ch4 |
| `data_quality_checks.csv` | DQ check history across 8 checks, 10 weeks | Ch4 |
| `daily_order_volume.csv` | 180 days of order counts. Downstream aggregation fed by `sales_summary_agg` after `daily_order_ingest`. Contains injected anomalies: spikes (large B2B orders), an unexplained weekday dip (Jan 31), and a 4-day weather-related dip (Feb 19–22, North + East carrier suspension). | Ch4 |

---

## Scripts/

### Ch2 — Query writing and optimisation

| File | Description |
|------|-------------|
| `02_sample_queries.sql` | 5 working demo queries: revenue by segment, top products, low inventory, lapsed customers, pipeline failure rate |
| `02_03_before.sql` | Slow query with performance issues — used as the starting point for the Ch2 optimisation demo |
| `02_03_after.sql` | Same query refactored with AI optimisation suggestions applied |
| `02_04_broken_before.sql` | 6 broken queries with deliberate faults, no hints — shown to AI for diagnosis (alias in WHERE, ambiguous column, missing GROUP BY, HAVING without GROUP BY, off-by-one date, divide by zero) |
| `02_04_broken_after.sql` | Same 6 queries with AI-suggested fixes applied |
| `02_04_broken_sql_additional_before.sql` | Additional broken SQL examples — before fixes |
| `02_04_broken_sql_additional_after.sql` | Additional broken SQL examples — after fixes |
| `02_complex_before.sql` | One-line monster query — feed to AI and ask it to refactor for readability |
| `02_complex_after.sql` | Same logic, refactored into clean CTEs |

### Ch3 — Documentation and knowledge sharing

| File | Description |
|------|-------------|
| `03_pipeline_config.json` | Full pipeline definition for `daily_order_ingest` — steps, DQ checks, SLA (60 min), alerts, and dependencies. Used as context in lineage, runbook, and stakeholder comms demos. |
| `03_runbook_daily_order_ingest.md` | AI-generated operational runbook for `daily_order_ingest` — reviewed and edited, used as the "good" output in Ch3 |
| `03_runbook_daily_order_ingest_old.md` | Earlier draft of the runbook — used to show the before/after of AI-assisted refinement |

### Ch4 — Reliability and incident response

| File | Description |
|------|-------------|
| `04_01_demo_data.md` | Sample `pipeline_runs` and `data_quality_checks` rows (markdown tables) — paste directly into the AI prompt for the reliability workflow demo |
| `04_03_schema_drift.sql` | Before/after DDL for the `products` table showing the `unit_price` → `sale_price` column rename — used in the schema drift demo |
| `04_05_demo_data.md` | 54-row slice of `daily_order_volume` (Jan–Feb 2024) with baseline context and anomaly notes. Used for the two-pass anomaly detection demo: run without weather context first, then add the storm note and rerun. |

### Ch5 — Responsible AI

| File | Description |
|------|-------------|
| `05_02_customer_summary.csv` | Aggregated customer data by segment (order count, total spend, avg order value) — used in the bias demo to show that AI assumptions about "best" customers don't always match the data |
| `05_06_sample_AI_policy.md` | One-page sample AI use policy for a data team — referenced in the operating model article |

### Reference

| File | Description |
|------|-------------|
| `sample_rows.md` | 5 sample rows per table for all 10 tables in markdown format — paste inline into prompts when AI needs data context without attaching a CSV |
