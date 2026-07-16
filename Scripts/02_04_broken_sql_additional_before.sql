-- Example 1
SELECT
    c.segment,
    SUM(o.total_amount) AS rev
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE rev > 10000
GROUP BY c.segment;


-- Example 2
SELECT
    order_id,
    status,
    total_amount
FROM orders
JOIN pipeline_runs ON pipeline_name = 'daily_order_ingest'
WHERE status = 'Failed';


-- Example 3
SELECT
    c.customer_id,
    c.contact_name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id;


-- Example 4
SELECT
    product_id,
    quantity_on_hand
FROM inventory
HAVING quantity_on_hand < 10;


-- Example 5
SELECT
    order_date,
    COUNT(*) AS orders
FROM orders
WHERE order_date BETWEEN '2024-06-01' AND '2024-06-29'
GROUP BY order_date
ORDER BY order_date;


-- Example 6
SELECT
    pipeline_name,
    failed_runs * 100 / total_runs AS failure_pct
FROM (
    SELECT
        pipeline_name,
        SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed_runs,
        COUNT(*) AS total_runs
    FROM pipeline_runs
    GROUP BY pipeline_name
) sub;
