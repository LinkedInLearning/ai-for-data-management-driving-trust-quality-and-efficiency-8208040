-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Slow query BEFORE optimisation — Ch2 video 02_03
-- This query is logically correct but uses correlated subqueries in the SELECT
-- list, hitting the orders table once per customer row. Feed to AI and ask it
-- to review for performance issues.
-- =============================================================================

-- Customer summary: total completed orders and spend
SELECT
    c.customer_id,
    c.contact_name,
    c.segment,
    c.region,
    (SELECT COUNT(*)
     FROM orders o
     WHERE o.customer_id = c.customer_id
       AND o.status = 3)            AS completed_orders,
    (SELECT SUM(o.total_amount)
     FROM orders o
     WHERE o.customer_id = c.customer_id
       AND o.status = 3)            AS total_spend
FROM customers c
ORDER BY total_spend DESC;
