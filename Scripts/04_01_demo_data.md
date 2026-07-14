# Demo Data — 04_01 Reliability Workflow

Sample rows from `pipeline_runs` and `data_quality_checks` for the 04_01 prompt demo.

---

## pipeline_runs (recent history — mix of success and failure)

| run_id | pipeline_name | start_time | end_time | status | rows_processed | error_message |
| --- | --- | --- | --- | --- | --- | --- |
| RUN0001 | daily_order_ingest | 2024-06-01 14:00:00 | 2024-06-01 14:08:49 | Success | 635 | |
| RUN0002 | sales_summary_agg | 2024-06-02 03:00:00 | 2024-06-02 03:01:55 | Success | 539 | |
| RUN0003 | inventory_sync | 2024-06-02 13:00:00 | 2024-06-02 13:14:30 | Success | 2589 | |
| RUN0004 | daily_order_ingest | 2024-06-03 01:00:00 | 2024-06-03 01:02:41 | Success | 3509 | |
| RUN0005 | product_catalog_load | 2024-06-03 16:00:00 | 2024-06-03 16:14:09 | Success | 1948 | |
| RUN0006 | product_catalog_load | 2024-06-04 03:00:00 | 2024-06-04 03:08:21 | **Failed** | 0 | Row count check failed: expected 1420 rows, got 847 |
| RUN0014 | customer_dim_refresh | 2024-06-08 06:00:00 | 2024-06-08 06:14:10 | **Failed** | 0 | Column 'unit_price' not found in source schema |
| RUN0015 | product_catalog_load | 2024-06-08 17:00:00 | 2024-06-08 17:14:23 | **Failed** | 0 | Row count check failed: expected 1420 rows, got 847 |

---

## data_quality_checks (recent results — all check types, including failures)

| check_id | table_name | check_name | description | run_date | passed | failed_row_count |
| --- | --- | --- | --- | --- | --- | --- |
| DQC0001 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-01 | True | 0 |
| DQC0002 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-08 | **False** | 2 |
| DQC0011 | orders | status_valid_values | Status in allowed list | 2024-04-01 | True | 0 |
| DQC0021 | order_items | positive_quantity | Quantity > 0 | 2024-04-01 | True | 0 |
| DQC0023 | order_items | positive_quantity | Quantity > 0 | 2024-04-15 | **False** | 1 |
| DQC0031 | order_items | price_matches_product | unit_price_at_order matches products.unit_price | 2024-04-01 | True | 0 |
| DQC0041 | inventory | non_negative_qty | quantity_on_hand >= 0 | 2024-04-01 | True | 0 |
| DQC0008 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-05-20 | **False** | 1 |
