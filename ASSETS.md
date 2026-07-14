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

## Files

### Core data (used across all chapters)

| File | Description | Used in |
|------|-------------|---------|
| `schema.sql` | DDL for all 9 tables | Ch1, Ch2, Ch3 |
| `warehouses.csv` | 5 warehouses by region | Ch1, Ch4 |
| `suppliers.csv` | 5 suppliers (Vendor A–E), domestic + international | Ch1 |
| `products.csv` | 15 products, generic names (Model A/B/X/Y, Type A/B) | Ch1, Ch2 |
| `customers.csv` | 25 customers, 4 segments, 5 regions | Ch1, Ch2 |
| `orders.csv` | 60 orders, 2024, mixed statuses | Ch2, Ch4 |
| `order_items.csv` | Line items for all orders | Ch2 |
| `inventory.csv` | Stock levels per product per warehouse | Ch1, Ch4 |

### Reliability / pipeline data (Ch4)

| File | Description |
|------|-------------|
| `pipeline_runs.csv` | 50 pipeline run records with injected failures and real error messages |
| `data_quality_checks.csv` | DQ check history across 8 checks, 10 weeks |
| `daily_order_volume.csv` | 180 days of order counts. Downstream aggregation fed by `sales_summary_agg` after `daily_order_ingest`. Contains injected anomalies: spikes (large B2B orders), an unexplained weekday dip (Jan 31), and a 4-day weather-related dip (Feb 19–22, North + East carrier suspension). |

### SQL scripts (Ch2)

| File | Description |
|------|-------------|
| `02_sample_queries.sql` | 5 working demo queries (revenue by segment, top products, low inventory, lapsed customers, pipeline failure rate) |
| `02_broken_sql.sql` | 6 broken queries with deliberate faults (alias in WHERE, ambiguous column, missing GROUP BY, HAVING without GROUP BY, off-by-one date, divide by zero) |
| `02_complex_before.sql` | One-line monster query — feed to AI and ask it to refactor |
| `02_complex_after.sql` | Same logic, refactored into clean CTEs |

### Pipeline / documentation assets (Ch3)

| File | Description |
|------|-------------|
| `03_pipeline_config.json` | Full pipeline definition for `daily_order_ingest` — steps, DQ checks, SLA, alerts, dependencies |
