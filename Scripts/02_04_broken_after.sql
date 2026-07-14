-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Broken SQL examples for Ch2 — Debugging Broken SQL with AI
-- Each block has a deliberate fault. Used to show AI-assisted diagnosis.
-- =============================================================================

-- ── EXAMPLE 1: Invalid column name 'rev' ──────────────────────────────────
SELECT
    c.segment,
    SUM(o.total_amount) AS rev
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE rev > 10000 
GROUP BY c.segment;


-- Fixed by AI
SELECT
    c.segment,
    SUM(o.total_amount) AS rev
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.segment
HAVING SUM(o.total_amount) > 10000;
