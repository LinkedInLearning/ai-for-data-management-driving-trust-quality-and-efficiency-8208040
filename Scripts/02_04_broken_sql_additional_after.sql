-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Broken SQL examples for Ch2 — Debugging Broken SQL with AI
-- Each block has a deliberate fault. Used to show AI-assisted diagnosis.
-- =============================================================================

-- ── EXAMPLE 1: wrong column alias in WHERE ───────────────────────────────────
-- Fault: referencing the alias 'rev' in WHERE — not valid in SQL Server
SELECT
    c.segment,
    SUM(o.total_amount) AS rev
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE rev > 10000          -- ❌ column alias not accessible in WHERE
GROUP BY c.segment;


-- ── EXAMPLE 2: ambiguous column reference ────────────────────────────────────
-- Fault: 'status' exists in both orders and pipeline_runs — ambiguous join
SELECT
    order_id,
    status,                -- ❌ ambiguous: which table?
    total_amount
FROM orders
JOIN pipeline_runs ON pipeline_name = 'daily_order_ingest'
WHERE status = 'Failed';


-- ── EXAMPLE 3: GROUP BY missing column ───────────────────────────────────────
-- Fault: contact_name selected but not in GROUP BY
SELECT
    c.customer_id,
    c.contact_name,        -- ❌ not in GROUP BY
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id;


-- ── EXAMPLE 4: HAVING without GROUP BY ───────────────────────────────────────
-- Fault: HAVING used as if it were WHERE, no GROUP BY present
SELECT
    product_id,
    quantity_on_hand
FROM inventory
HAVING quantity_on_hand < 10;  -- ❌ should be WHERE


-- ── EXAMPLE 5: OFF-BY-ONE in date range ──────────────────────────────────────
-- Fault: both endpoints exclusive — BETWEEN is inclusive but the intent
-- is 'last full month'; using hardcoded dates that exclude the last day
SELECT
    order_date,
    COUNT(*) AS orders
FROM orders
WHERE order_date BETWEEN '2024-06-01' AND '2024-06-29'  -- ❌ misses June 30
GROUP BY order_date
ORDER BY order_date;


-- ── EXAMPLE 6: Division by zero ──────────────────────────────────────────────
-- Fault: no guard when total_runs could be 0 for a newly added pipeline
SELECT
    pipeline_name,
    failed_runs * 100 / total_runs AS failure_pct  -- ❌ divide by zero risk
FROM (
    SELECT
        pipeline_name,
        SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed_runs,
        COUNT(*) AS total_runs
    FROM pipeline_runs
    GROUP BY pipeline_name
) sub;
