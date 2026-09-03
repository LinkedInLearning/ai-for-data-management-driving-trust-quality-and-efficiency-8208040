-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Sample working query for Ch5
-- AI generated query from a bad prompt
-- CURRENT_DATE is not a T-SQL function
-- Column names are guessed and incorrect
-- =============================================================================

SELECT
    c.segment,
    o.status,
    COUNT(DISTINCT o.order_id)      AS order_count,
    COUNT(DISTINCT o.customer_id)   AS customer_count,
    SUM(o.order_total)              AS total_revenue,
    AVG(o.order_total)              AS avg_order_value
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY 
    c.segment,
    o.status
ORDER BY 
    c.segment,
    o.status;
