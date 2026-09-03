-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Sample working query for Ch2 — Query Writing and Optimisation
-- Revenue by customer segment this year
-- =============================================================================

SELECT
    c.segment,
    COUNT(DISTINCT o.order_id)  AS order_count,
    SUM(o.total_amount)         AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 3      -- Completed orders only
    AND YEAR(o.order_date) = 2024
GROUP BY c.segment
ORDER BY total_revenue DESC;