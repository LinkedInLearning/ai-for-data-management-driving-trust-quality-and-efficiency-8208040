-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Sample working query for Ch2 — Query Writing and Optimisation
-- Revenue by customer segment and year, using only completed orders (status = 3)
-- Sorted by year desc then revenue desc so you can scan recent trends first
-- and spot segment mix shifts year-over-year.
-- =============================================================================

SELECT
    c.segment,
    YEAR(o.order_date)          AS order_year,
    COUNT(DISTINCT o.order_id)  AS completed_order_count,
    SUM(o.total_amount)         AS total_revenue,
    AVG(o.total_amount)         AS avg_order_value
FROM orders AS o
INNER JOIN customers AS c 
    ON c.customer_id = o.customer_id
WHERE o.status = 3
GROUP BY 
    c.segment,
    YEAR(o.order_date)
ORDER BY 
    order_year DESC,
    total_revenue DESC;