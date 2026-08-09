-- ============================================================
-- SQL RETAIL ANALYTICS
-- INTERMEDIATE SQL QUERIES
-- ============================================================


-- ============================================================
-- 1. Show orders with customer information
-- ============================================================

SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;


-- ============================================================
-- 2. Show orders with employee information
-- ============================================================

SELECT
    o.order_id,
    o.order_date,
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department
FROM orders AS o
JOIN employees AS e
    ON o.employee_id = e.employee_id
ORDER BY o.order_date;


-- ============================================================
-- 3. Show order items with product information
-- ============================================================

SELECT
    oi.order_id,
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;


-- ============================================================
-- 4. Calculate revenue for every order item
-- ============================================================

SELECT
    oi.item_id,
    oi.order_id,
    p.product_name,
    oi.quantity,
    p.price,
    ROUND(oi.quantity * p.price, 2) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
ORDER BY revenue DESC;


-- ============================================================
-- 5. Calculate total revenue
-- ============================================================

SELECT
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;


-- ============================================================
-- 6. Calculate total quantity of products sold
-- ============================================================

SELECT
    SUM(quantity) AS total_units_sold
FROM order_items;


-- ============================================================
-- 7. Revenue by product
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY revenue DESC;


-- ============================================================
-- 8. Top 10 products by revenue
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 9. Revenue by category
-- ============================================================

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- ============================================================
-- 10. Top 5 categories by revenue
-- ============================================================

SELECT
    p.category,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 5;


-- ============================================================
-- 11. Orders per employee
-- ============================================================

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    COUNT(o.order_id) AS orders_handled
FROM employees AS e
LEFT JOIN orders AS o
    ON e.employee_id = o.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department
ORDER BY orders_handled DESC;


-- ============================================================
-- 12. Revenue handled by each employee
-- ============================================================

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM employees AS e
JOIN orders AS o
    ON e.employee_id = o.employee_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department
ORDER BY revenue DESC;


-- ============================================================
-- 13. Customer order count
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS number_of_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY number_of_orders DESC;


-- ============================================================
-- 14. Customer spending
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_spent
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC;


-- ============================================================
-- 15. Top 10 customers by spending
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_spent
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================================
-- 16. Average order value
-- ============================================================

SELECT
    ROUND(SUM(oi.quantity * p.price) / COUNT(DISTINCT o.order_id), 2)
        AS average_order_value
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id;


-- ============================================================
-- 17. Number of orders per month
-- ============================================================

SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY month
ORDER BY month;


-- ============================================================
-- 18. Revenue per month
-- ============================================================

SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;


-- ============================================================
-- 19. Sales by customer city
-- ============================================================

SELECT
    c.city,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY revenue DESC;


-- ============================================================
-- 20. Best-selling products by quantity
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY units_sold DESC
LIMIT 10;