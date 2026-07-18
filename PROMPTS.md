# Prompts

The sample prompts used in each video demo, organised by chapter. Where a prompt requires data or a file, a placeholder indicates what to paste in.

## Chapter 1

### 01_01

```text
Here's the schema for a database I've just inherited. I need to understand it quickly. 
Please: 
1. Summarise what this database tracks — what's the core business domain? 
2. Identify the key entities and how they relate to each other 
3. Flag any columns that look like potential data quality risks — nullability gaps, inconsistent naming, missing constraints 
4. Note anything that looks undocumented or unusual
```

### 01_02

```
Here's the schema for a distribution and fulfilment company.
I need to understand how data flows through it before I start writing queries. Please:
1. Map the explicit relationships — tables with FK constraints and the direction of the dependency, include an ER diagram.
2. Identify any implicit relationships — columns that look like join keys but have no FK defined (e.g. shared IDs, naming patterns)
3. Flag any tables that look orphaned or loosely connected — where the join path isn't obvious from the schema alone
4. For the orders → order_items → products chain specifically, are there any gaps or assumptions I should be aware of?
```

### 01_03

```
I'm working with a database for a distribution and fulfillment company. Here's the DDL for one of the key tables, along with some sample rows.

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status TINYINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    warehouse_id INT NOT NULL,
    notes NVARCHAR(500) NULL
);

Sample Rows:
[paste sample rows here]

Please generate a data dictionary for this table. For each column include:

- Column name
- Data type
- Nullable (yes/no)
- Description
- Example values or known value ranges where you can infer them
- Any notes or caveats (flag anything where business meaning is unclear from the schema alone)

Output as a Markdown table.
```

### 01_04

```
I work for a distribution and fulfilment company. Here's the schema for our core operational database. 
Please explain this data model to a non-technical business stakeholder — someone who understands the business but doesn't read SQL. They need to know:
1. What data we hold and what business processes it supports
2. How the key entities relate to each other in plain English (no technical jargon, no mention of foreign keys or joins)
3. What questions this data could answer for them — for example, what could we report on, what can we track over time?

Keep it concise — no longer than 3 short paragraphs.
```

## Chapter 2

### 02_01

```
I'm working with a SQL Server database for a distribution and fulfilment company. Here's the schema.
Write a query to show total revenue by customer segment for 2024, but only include completed orders. 
I want the segment name, number of orders, and total revenue, sorted by total revenue descending.
```

### 02_02

```
I'm working with a SQL Server database for a distribution and fulfilment company. Schema attached.
Write a query to answer this business question: which customer segments are generating the most revenue, and is that changing over time?
I need:
- One row per segment per year
- Columns: segment, year, number of completed orders, total revenue, average order value
- Only include completed orders (status = 3)
- Sorted by year descending, then total revenue descending
Use SQL Server syntax. Add a comment at the top explaining what the query does.
```

### 02_03

```
Here's a SQL Server query that returns revenue by customer segment and year. It's correct but I want to make sure it's written efficiently.
Please review it for performance issues. For each issue you find:
1. Explain what the problem is and why it matters
2. Show the corrected version
3. Note whether this would make a meaningful difference on a small dataset vs. a large one
Focus on the WHERE clause, JOIN efficiency, and anything that might prevent index use.
Don't suggest adding indexes — assume the schema is fixed.
```

### 02_04

```
I'm getting this error in SQL Server: “Msg 207, Level 16, State 1, Line 13
Invalid column name 'rev'.”
Here's the query:

<Enter Query>

What's causing this and how do I fix it?
```

### 02_05

```
Here's a SQL Server query that works but is very hard to read and maintain.

<Enter Query>

Please refactor it for readability and maintainability.

Use CTEs with descriptive names, add comments explaining what each section does, format the SQL consistently, and replace any magic numbers with clearly named expressions.

Don't change the logic — the output should be identical to the original.
```

## Chapter 3

### 03_01

```

I'm auditing the documentation gaps in our operational database. Here is the DDL for our schema
For each table, identify:
1. Columns where the name or data type doesn't make the purpose obvious
1. Foreign key relationships that might be non-obvious to a new team member
1. Any columns that look like they store coded or enumerated values where you'd need a lookup to understand them
Don't invent meanings — just flag what's unclear. I'll add the business context separately.
```

### 03_03

```
Attached is the config for one of our data pipelines:
Write a lineage summary that covers:
1. Upstream inputs and their owners
1. Key transformation logic and business rules applied
1. Downstream consumers and what they depend on from this pipeline
1. What breaks — and for whom — if this pipeline fails
Keep it concise enough to live in a wiki page. No longer than 300 words.
```

### 03_04

```
I need to write an operational runbook for a data pipeline. Pipeline config is attached.
Known failure modes we've seen in production:
- customer_id validation fails when the upstream system sends incomplete records — rows are dropped
- Row count threshold check fails on bank holidays when order volume drops below 100
- The sales_summary refresh occasionally times out when the orders table is under heavy query load
Draft a runbook that includes:
1. Trigger — what conditions activate this runbook
1. Pre-checks — what to verify before taking any action
1. Step-by-step procedure — what to do, in order
1. Rollback — how to undo changes if the fix makes things worse
1. Escalation path — when and who to contact if the procedure doesn't resolve it
Write it in markdown to be followed by a data engineer who knows SQL but didn't build this pipeline. Use numbered steps. Be specific — don't say "check the logs" without saying which logs.
```

### 03_05

```
Here is the config for our daily_order_ingest pipeline:

Write an explanation for a business owner who needs to decide whether to proceed with a planned Monday morning product launch, given that this pipeline has been intermittently failing the row count threshold check.
The explanation should:
1. Describe what this pipeline does in plain English — no technical jargon
2. Explain what happens to the business if it fails or runs late
3. State the specific risk for Monday's launch in concrete terms — not "may cause delays," but what would actually happen and when it would be resolved

Be no longer than 200 words.
```

## Chapter 4

### 04_01

```
My team doesn't have a formal data reliability workflow. Here's what we're working with:
Recent pipeline run history:
 [paste sample rows from pipeline_runs]
Recent data quality check results:
 [paste sample rows from data_quality_checks]
Based on this, draft a starting-point reliability workflow that covers:
1. What to monitor proactively — key signals and thresholds to watch
2. How to triage an incident when a pipeline fails or a DQ check fails
3. What a post-incident review should capture to prevent recurrence
Keep each section practical — something we can implement this week, not a theoretical framework. No longer than 400 words.
```

### 04_02

```
A pipeline has just failed. Here are the details:
Error: Column 'unit_price' not found in source schema
Pipeline config attached.
Recent run history:
 [paste RUN0014 row from 04_01_demo_data.md]
Please:
1. Categorise this failure — config error, data issue, infrastructure, or dependency failure
1. Identify the most likely root cause
1. Suggest recovery steps in priority order
1. Flag any downstream pipelines or reports likely affected
```

### 04_03

```
Our products table schema has changed. Here is the before and after DDL:
Before:
```sql
[paste before DDL]
```

After:
```sql
[paste after DDL]
```

Pipeline documentation attached.
Please:
1. Classify this change — breaking or non-breaking, and why
2. List every query, pipeline, or report likely affected
3. Suggest remediation steps in priority order
4. Flag any risk of data inconsistency during the transition
```

### 04_05

```
Here is daily order volume for our distribution company over the past 30 days.
Context about normal variation:
- Weekday average: ~85–90 orders
- Weekend average: ~60–70 orders
- Bank holidays typically see 40–60% of normal weekday volume
Please:
1. Identify any days where order volume looks anomalous given the expected ranges above
1. For each flagged day, explain whether it looks like an explainable business event or a potential operational issue worth investigating
1. Suggest a threshold rule I could use to auto-flag similar anomalies going forward
Don't flag expected low-volume days as anomalies if they match the variation patterns above.
```

### 04_06

```
Incident: daily_order_ingest pipeline failed at 01:00. The morning dashboard is showing yesterday's data. No orders have been lost — this is a reporting issue, not a fulfilment issue.

Current status: Engineering team is investigating. Root cause not yet confirmed.
Next update in: 30 minutes.

Draft two versions:

1. For the data engineering team — technical detail, what's being investigated, next steps
2. For the Head of Operations — business impact, what they can and can't rely on right now, when they'll hear back

Keep the stakeholder version under 100 words. No technical jargon in the stakeholder version. Do not invent an ETA for full resolution — use "under investigation."
```

## Chapter 5

### 05_02

```
I'm planning to use AI to help prioritise which customers to focus our account management resources on. Before I do, I want to assess the bias risks in my dataset. 

Attached is a summary of our customer data:

Please assess:

1. Are there characteristics in this dataset that could produce systematically skewed outputs if AI uses it to rank or prioritise customers?
1. Which segments or regions might be disadvantaged by an AI model trained on this data?
1. What checks would you recommend before trusting AI-generated customer prioritisation from this dataset?
Be specific — reason through the actual data characteristics, not generic bias warnings.
```

### 05_04

```
Write a SQL query to show total revenue by customer segment for the last 90 days, including cancelled orders separately. 
```
