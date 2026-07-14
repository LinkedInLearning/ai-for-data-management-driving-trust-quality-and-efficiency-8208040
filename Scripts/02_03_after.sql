SET STATISTICS TIME, IO ON

-- Customer summary: total completed orders and spend
-- (correlated subqueries — hits the orders table once per customer row)
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

-- rewritten by AI
SELECT
    c.customer_id,
    c.contact_name,
    c.segment,
    c.region,
    COALESCE(o.completed_orders, 0) AS completed_orders,
    COALESCE(o.total_spend,       0) AS total_spend
FROM customers c
LEFT JOIN (
    SELECT
        customer_id,
        COUNT(*)          AS completed_orders,
        SUM(total_amount) AS total_spend
    FROM orders
    WHERE status = 3
    GROUP BY customer_id
) o ON o.customer_id = c.customer_id
ORDER BY total_spend DESC;