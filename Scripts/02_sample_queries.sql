-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Sample working queries for Ch2 — Query Writing and Optimisation
-- =============================================================================

-- 1. Revenue by customer segment this year
SELECT
    c.segment,
    COUNT(DISTINCT o.order_id)  AS order_count,
    SUM(o.total_amount)         AS total_revenue,
    AVG(o.total_amount)         AS avg_order_value
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01'
  AND o.status = 3  -- 3=Completed
GROUP BY c.segment
ORDER BY total_revenue DESC;


-- 2. Top 5 products by units sold
SELECT TOP 5
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o   ON o.order_id   = oi.order_id
WHERE o.status IN (3, 2)  -- 3=Completed, 2=Shipped
GROUP BY p.product_name, p.category
ORDER BY total_units_sold DESC;


-- 3. Inventory below reorder threshold (50 units)
SELECT
    p.product_name,
    p.category,
    w.warehouse_name,
    w.region,
    i.quantity_on_hand,
    s.supplier_name,
    s.lead_time_days
FROM inventory i
JOIN products   p ON p.product_id   = i.product_id
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
JOIN suppliers  s ON s.supplier_id  = p.supplier_id
WHERE i.quantity_on_hand < 50
ORDER BY i.quantity_on_hand ASC;


-- 4. Customers with no orders in the last 90 days
SELECT
    c.customer_id,
    c.contact_name,
    c.segment,
    c.region,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.contact_name, c.segment, c.region
HAVING MAX(o.order_date) < DATEADD(DAY, -90, GETDATE())
    OR MAX(o.order_date) IS NULL
ORDER BY last_order_date ASC;


-- 5. Pipeline failure rate by pipeline name (last 30 days)
SELECT
    pipeline_name,
    COUNT(*)                                         AS total_runs,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed_runs,
    CAST(
        SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) AS DECIMAL(5,2)
    )                                                AS failure_rate_pct
FROM pipeline_runs
WHERE start_time >= DATEADD(DAY, -30, GETDATE())
GROUP BY pipeline_name
ORDER BY failure_rate_pct DESC;
