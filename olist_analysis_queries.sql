USE olist;

-- Query 1: Order Status Overview
SELECT order_status, COUNT(*) as total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Query 2: Total Revenue from Delivered Orders
SELECT 
    ROUND(SUM(oi.price), 2) as total_revenue,
    ROUND(SUM(oi.freight_value), 2) as total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) as total_combined,
    COUNT(DISTINCT oi.order_id) as total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Query 3: Monthly Revenue Trend
SELECT 
    YEAR(o.order_purchase_timestamp) as year,
    MONTH(o.order_purchase_timestamp) as month,
    ROUND(SUM(oi.price), 2) as revenue,
    COUNT(DISTINCT o.order_id) as total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;

-- Query 4: Lost Revenue from Cancelled Orders
SELECT 
    o.order_status,
    COUNT(*) as total_orders,
    ROUND(SUM(oi.price), 2) as lost_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('canceled', 'unavailable')
GROUP BY o.order_status;

-- Query 5: Late Delivery Analysis
SELECT 
    COUNT(*) as total_delivered,
    SUM(CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) as late_orders,
    ROUND(SUM(CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as late_percentage
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

-- Query 6: Top 10 Sellers by Revenue
SELECT 
    oi.seller_id,
    ROUND(SUM(oi.price), 2) as total_revenue,
    COUNT(DISTINCT oi.order_id) as total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 7: Late Orders by State
SELECT 
    c.customer_state,
    COUNT(*) as total_orders,
    SUM(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) as late_orders,
    ROUND(SUM(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as late_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_percentage DESC;