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