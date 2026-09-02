# AI for Data Management: Driving Trust, Quality, and Efficiency
This is the repository for the LinkedIn Learning course `AI for Data Management: Driving Trust, Quality, and Efficiency`. The full course is available from [LinkedIn Learning][lil-course-url].

![lil-thumbnail-url]

## Course Description
AI is transforming how data managers work, from diagnosing failed pipelines to generating documentation and validating SQL. In this course, discover practical, hands-on techniques for using AI to investigate unfamiliar data systems, troubleshoot operational incidents, optimize queries, and maintain data quality at scale. Explore responsible AI practices—addressing bias, hallucinations, privacy, and human oversight—so you can use AI confidently without compromising trust or security. By the end of this course, you'll be equipped with cutting-edge strategies to incorporate AI into your current data lifecycle.

## Learning Objectives
Evaluate and prioritize at least three AI use cases for your data team using business impact, implementation effort, and operational risk.
Create a clear AI-assisted data system brief that documents dataset structure, schema relationships, and plain-language explanations for stakeholders.
Generate, validate, and optimize SQL or transformation logic with AI and verify correctness before implementation.
Troubleshoot common pipeline, integration, and operations issues by using AI to form and test evidence-based scenarios.
Design and apply responsible AI practices for data work that address privacy, security, bias, hallucinations, and human oversight.

_See the readme file in the main branch for updated instructions and information._
## Instructions
This repository has branches for each of the videos in the course. You can use the branch pop up menu in github to switch to a specific branch and take a look at the course at that stage, or you can add `/tree/BRANCH_NAME` to the URL to go to the branch you want to access.

## Branches
The branches are structured to correspond to the videos in the course. The naming convention is `CHAPTER#_MOVIE#`. As an example, the branch named `02_03` corresponds to the second chapter and the third video in that chapter. 
Some branches will have a beginning and an end state. These are marked with the letters `b` for "beginning" and `e` for "end". The `b` branch contains the code as it is at the beginning of the movie. The `e` branch contains the code as it is at the end of the movie. The `main` branch holds the final state of the code when in the course.

When switching from one exercise files branch to the next after making changes to the files, you may get a message like this:

    error: Your local changes to the following files would be overwritten by checkout:        [files]
    Please commit your changes or stash them before you switch branches.
    Aborting

To resolve this issue:
	
    Add changes to git using this command: git add .
	Commit changes using this command: git commit -m "some message"

## Installing
1. To use these exercise files, you must have the following installed:
	- [list of requirements for course]
2. Clone this repository into your local machine using the terminal (Mac), CMD (Windows), or a GUI tool like SourceTree.
3. [Course-specific instructions]

## Course Scenario

All assets follow LinkedIn Learning data guidelines:
- No product brand names (use "Model X", "Type A", etc.)
- No vendor names (use "Vendor A", "Vendor B", etc.)
- No real store/platform names
- Generic regions (North, South, East, West, Central)

The scenario is a generic distribution and fulfilment company. They have products across several categories (Storage, Electronics, Furniture, Accessories, Infrastructure), sell to customers in four segments (Enterprise, SMB, Government, Education), and run a small set of data pipelines to keep the warehouse in sync with the order management system.

This single scenario threads through all five chapters — you explore the schema in Ch1, write queries against it in Ch2, document it in Ch3, diagnose pipeline failures in Ch4, and discuss governance risks around it in Ch5.

## Repository Contents

```
Database/      — schema DDL, seed data CSVs, sample rows reference, and the PowerShell load script
Scripts/ch02/  — SQL scripts for Chapter 2 (query writing and optimisation)
Scripts/ch03/  — config files and runbooks for Chapter 3 (documentation)
Scripts/ch04/  — demo data and SQL for Chapter 4 (reliability and incident response)
Scripts/ch05/  — data and policy docs for Chapter 5 (responsible AI)
```

### Database/

| File | Description | Used in |
|------|-------------|---------|
| `schema.sql` | DDL for all 10 tables (SQL Server) | Ch1, Ch2, Ch3 |
| `New-SampleDatabase.ps1` | PowerShell script (dbatools) to create the database and load all CSVs into SQL Server | Setup |
| `sample_rows.md` | 5 sample rows per table for all 10 tables in markdown format — reference doc for pasting data context inline into prompts | All chapters |
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

### Scripts/ch02/

| File | Description |
|------|-------------|
| `02_sample_queries.sql` | 5 working demo queries: revenue by segment, top products, low inventory, lapsed customers, pipeline failure rate |
| `02_03_before.sql` | Slow query with performance issues — starting point for the optimisation demo |
| `02_03_after.sql` | Same query with AI optimisation suggestions applied |
| `02_04_broken_before.sql` | 6 broken queries with deliberate faults, no hints — shown to AI for diagnosis (alias in WHERE, ambiguous column, missing GROUP BY, HAVING without GROUP BY, off-by-one date, divide by zero) |
| `02_04_broken_after.sql` | Same 6 queries with AI-suggested fixes applied |
| `02_04_broken_sql_additional_before.sql` | Additional broken SQL examples — before fixes |
| `02_04_broken_sql_additional_after.sql` | Additional broken SQL examples — after fixes |
| `02_complex_before.sql` | One-line monster query — feed to AI and ask it to refactor for readability |
| `02_complex_after.sql` | Same logic, refactored into clean CTEs |

### Scripts/ch03/

| File | Description |
|------|-------------|
| `03_pipeline_config.json` | Full pipeline definition for `daily_order_ingest` — steps, DQ checks, SLA (60 min), alerts, and dependencies. Used as prompt context in lineage, runbook, and stakeholder comms demos. |
| `03_runbook_daily_order_ingest.md` | AI-generated operational runbook for `daily_order_ingest` — reviewed and edited output used in the Ch3 runbook demo |

### Scripts/ch04/

| File | Description |
|------|-------------|
| `04_01_demo_data.md` | Sample `pipeline_runs` and `data_quality_checks` rows (markdown tables) — paste directly into the AI prompt for the reliability workflow demo |
| `04_03_schema_drift.sql` | Before/after DDL for the `products` table showing the `unit_price` → `sale_price` column rename — used in the schema drift demo |
| `04_05_demo_data.md` | 54-row slice of `daily_order_volume` (Jan–Feb 2024) with baseline context and anomaly notes. Used for the two-pass anomaly detection demo: run without weather context first, then add the storm note and rerun. |

### Scripts/ch05/

| File | Description |
|------|-------------|
| `05_02_customer_summary.csv` | Aggregated customer data by segment (order count, total spend, avg order value) — used in the bias demo to show that AI assumptions about "best" customers don't always match the data |
| `05_06_sample_AI_policy.md` | One-page sample AI use policy for a data team — referenced in the operating model article |

## Instructor

Jess Pomfret - Database Platform Architect and Microsoft MVP

Jess has been working extensively with SQL Server since back in 2011. An expert in the problem-solving aspects of process automation with PowerShell, she is a frequent contributor to dbatools and dbachecks, the open-source PowerShell modules that help automate the management and maintenance of SQL Server instances. Over the course of her career, she has also contributed several configuration resources to the SqlServerDsc module.

Jess grew up in the southwest of England, where she currently lives and works for Data Masterminds.

                            

Check out my other courses on [LinkedIn Learning](https://www.linkedin.com/learning/instructors/jess-pomfret?u=104).


[0]: # (Replace these placeholder URLs with actual course URLs)

[lil-course-url]: https://www.linkedin.com/learning/ai-for-data-management-driving-trust-quality-and-efficiency
[lil-thumbnail-url]: https://media.licdn.com/dms/image/v2/D560DAQF2wHcLqE6pNw/learning-public-crop_675_1200/B56Z9x12nNJoAY-/0/1784321371395?e=2147483647&v=beta&t=p8H3uK-OAjSNXzgYIuT9FLlljlqJCduanHwknqgNbOI

