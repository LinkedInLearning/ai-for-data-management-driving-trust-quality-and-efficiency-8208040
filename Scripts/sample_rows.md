# Sample Rows — AI for Data Management Sample Database

Distribution and fulfilment company. 5 sample rows per table.

> **orders.status codes:** 1=Processing | 2=Shipped | 3=Completed | 4=Cancelled
> **pipeline_runs.status:** Success | Failed | Running

---

## warehouses

| warehouse_id | warehouse_name | region | capacity_units |
| --- | --- | --- | --- |
| WH001 | North Region Warehouse | North | 10000 |
| WH002 | South Region Warehouse | South | 8000 |
| WH003 | East Region Warehouse | East | 12000 |
| WH004 | West Region Warehouse | West | 9000 |
| WH005 | Central Fulfilment Hub | Central | 15000 |

## suppliers

| supplier_id | supplier_name | supplier_type | lead_time_days |
| --- | --- | --- | --- |
| SUP001 | Vendor A | Domestic | 3 |
| SUP002 | Vendor B | Domestic | 5 |
| SUP003 | Vendor C | International | 14 |
| SUP004 | Vendor D | International | 21 |
| SUP005 | Vendor E | Domestic | 7 |

## products

| product_id | product_name | category | unit_price | supplier_id |
| --- | --- | --- | --- | --- |
| PRD001 | Storage Unit - Model A | Storage | 149.99 | SUP001 |
| PRD002 | Storage Unit - Model B | Storage | 249.99 | SUP001 |
| PRD003 | Display Panel - Model X | Electronics | 599.99 | SUP002 |
| PRD004 | Display Panel - Model Y | Electronics | 399.99 | SUP002 |
| PRD005 | Desk Unit - Standard | Furniture | 189.99 | SUP003 |

## customers

| customer_id | contact_name | region | segment | account_created_date |
| --- | --- | --- | --- | --- |
| CUST001 | Taylor Smith | East | SMB | 2021-08-17 |
| CUST002 | Casey Brown | Central | Enterprise | 2022-08-28 |
| CUST003 | Finley Johnson | North | Enterprise | 2021-08-12 |
| CUST004 | Avery Moore | Central | Enterprise | 2022-07-29 |
| CUST005 | Quinn Allen | West | SMB | 2022-04-05 |

## orders

| order_id | customer_id | order_date | status | total_amount |
| --- | --- | --- | --- | --- |
| ORD0001 | CUST009 | 2024-10-10 | 4 | 3301.39 |
| ORD0002 | CUST022 | 2024-02-28 | 1 | 3102.52 |
| ORD0003 | CUST025 | 2024-05-16 | 4 | 2261.32 |
| ORD0004 | CUST004 | 2024-05-30 | 3 | 595.64 |
| ORD0005 | CUST001 | 2024-05-14 | 2 | 2678.77 |

## order_items

| item_id | order_id | product_id | quantity | unit_price_at_order |
| --- | --- | --- | --- | --- |
| ITEM00001 | ORD0001 | PRD005 | 10 | 189.99 |
| ITEM00002 | ORD0001 | PRD015 | 4 | 199.99 |
| ITEM00003 | ORD0002 | PRD004 | 5 | 399.99 |
| ITEM00004 | ORD0002 | PRD011 | 9 | 79.99 |
| ITEM00005 | ORD0002 | PRD014 | 8 | 449.99 |

## inventory

| inventory_id | product_id | warehouse_id | quantity_on_hand | last_updated |
| --- | --- | --- | --- | --- |
| INV0001 | PRD001 | WH002 | 353 | 2024-07-24 |
| INV0002 | PRD001 | WH001 | 321 | 2024-06-16 |
| INV0003 | PRD001 | WH003 | 52 | 2024-07-15 |
| INV0004 | PRD002 | WH005 | 400 | 2024-06-03 |
| INV0005 | PRD002 | WH001 | 177 | 2024-07-05 |

## pipeline_runs

| run_id | pipeline_name | start_time | end_time | status | rows_processed | error_message |
| --- | --- | --- | --- | --- | --- | --- |
| RUN0001 | daily_order_ingest | 2024-06-01 14:00:00 | 2024-06-01 14:08:49 | Success | 635 |  |
| RUN0002 | sales_summary_agg | 2024-06-02 03:00:00 | 2024-06-02 03:01:55 | Success | 539 |  |
| RUN0003 | inventory_sync | 2024-06-02 13:00:00 | 2024-06-02 13:14:30 | Success | 2589 |  |
| RUN0004 | daily_order_ingest | 2024-06-03 01:00:00 | 2024-06-03 01:02:41 | Success | 3509 |  |
| RUN0005 | product_catalog_load | 2024-06-03 16:00:00 | 2024-06-03 16:14:09 | Success | 1948 |  |

## data_quality_checks

| check_id | table_name | check_name | description | run_date | passed | failed_row_count |
| --- | --- | --- | --- | --- | --- | --- |
| DQC0001 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-01 | True | 0 |
| DQC0002 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-08 | False | 2 |
| DQC0003 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-15 | True | 0 |
| DQC0004 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-22 | True | 0 |
| DQC0005 | orders | no_null_customer_id | NOT NULL check on customer_id | 2024-04-29 | True | 0 |

## daily_order_volume

| report_date | order_count | day_type |
| --- | --- | --- |
| 2024-01-01 | 88 | weekday |
| 2024-01-02 | 88 | weekday |
| 2024-01-03 | 85 | weekday |
| 2024-01-04 | 74 | weekday |
| 2024-01-05 | 84 | weekday |
