-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Complex SQL BEFORE refactoring — Ch2 video 02_05
-- This is deliberately messy: no formatting, magic numbers, repeated subqueries,
-- unclear aliases. Feed this to AI and show the refactored result.
-- =============================================================================

select c.customer_id,c.contact_name,c.segment,c.region,count(o.order_id),sum(o.total_amount),sum(o.total_amount)/count(o.order_id),case when sum(o.total_amount)>5000 then 'High' when sum(o.total_amount)>2000 then 'Medium' else 'Low' end,
(select count(*) from orders o2 where o2.customer_id=c.customer_id and o2.status=4),
(select top 1 p.category from order_items oi join products p on p.product_id=oi.product_id join orders o3 on o3.order_id=oi.order_id where o3.customer_id=c.customer_id group by p.category order by count(*) desc)
from customers c join orders o on o.customer_id=c.customer_id where o.status<>4 and o.order_date>='2024-01-01' group by c.customer_id,c.contact_name,c.segment,c.region having count(o.order_id)>=2 order by sum(o.total_amount) desc;

-- =============================================================================
-- Customer Order Summary Report
-- Returns active customers (2024 onwards) with 2+ non-cancelled orders,
-- ranked by total spend descending.
-- =============================================================================

WITH

-- Completed orders placed in the reporting period (excludes cancelled orders)
ActiveOrders AS (
    SELECT
        order_id,
        customer_id,
        total_amount,
        order_date,
        status
    FROM orders
    WHERE status <> 4            -- 4 = Cancelled
      AND order_date >= '2024-01-01'
),

-- Per-customer aggregates across their active orders
CustomerOrderStats AS (
    SELECT
        customer_id,
        COUNT(order_id)                         AS total_orders,
        SUM(total_amount)                       AS total_spend,
        SUM(total_amount) / COUNT(order_id)     AS avg_order_value
    FROM ActiveOrders
    GROUP BY customer_id
    HAVING COUNT(order_id) >= 2   -- Only customers with at least 2 active orders
),

-- Number of cancelled orders per customer (reported separately for context)
CancelledOrderCounts AS (
    SELECT
        customer_id,
        COUNT(*) AS cancelled_order_count
    FROM orders
    WHERE status = 4              -- 4 = Cancelled
    GROUP BY customer_id
),

-- The single product category each customer has ordered most frequently
TopCategoryPerCustomer AS (
    SELECT
        o.customer_id,
        p.category AS top_category,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY COUNT(*) DESC
        ) AS category_rank
    FROM order_items  oi
    JOIN products     p  ON p.product_id  = oi.product_id
    JOIN orders       o  ON o.order_id    = oi.order_id
    GROUP BY o.customer_id, p.category
)

-- =============================================================================
-- Final output: one row per qualifying customer
-- =============================================================================
SELECT
    c.customer_id,
    c.contact_name,
    c.segment,
    c.region,

    -- Order volume & value metrics
    cos.total_orders,
    cos.total_spend,
    cos.avg_order_value,

    -- Spend tier derived from total spend
    CASE
        WHEN cos.total_spend > 5000 THEN 'High'
        WHEN cos.total_spend > 2000 THEN 'Medium'
        ELSE                             'Low'
    END                                         AS spend_tier,

    -- Cancelled orders are tracked but do not affect the spend/order metrics above
    COALESCE(coc.cancelled_order_count, 0)      AS cancelled_order_count,

    tc.top_category

FROM customers              c
JOIN CustomerOrderStats     cos  ON cos.customer_id = c.customer_id
LEFT JOIN CancelledOrderCounts coc ON coc.customer_id = c.customer_id
JOIN TopCategoryPerCustomer tc   ON tc.customer_id  = c.customer_id
                                 AND tc.category_rank = 1

ORDER BY cos.total_spend DESC;