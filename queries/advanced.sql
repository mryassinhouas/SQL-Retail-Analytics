-- ============================================================
-- SQL RETAIL ANALYTICS
-- ADVANCED SQL QUERIES
-- ============================================================


-- ============================================================
-- 1. Rank products by revenue
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue,
    RANK() OVER (
        ORDER BY SUM(oi.quantity * p.price) DESC
    ) AS revenue_rank
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY revenue_rank;


-- ============================================================
-- 2. Rank customers by total spending
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_spent,
    RANK() OVER (
        ORDER BY SUM(oi.quantity * p.price) DESC
    ) AS customer_rank
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
ORDER BY customer_rank;


-- ============================================================
-- 3. Monthly revenue with month-to-month difference
-- ============================================================

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        ROUND(SUM(oi.quantity * p.price), 2) AS revenue
    FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY month
)

SELECT
    month,
    revenue,
    ROUND(
        revenue - LAG(revenue) OVER (ORDER BY month),
        2
    ) AS revenue_difference
FROM monthly_sales
ORDER BY month;


-- ============================================================
-- 4. Monthly revenue growth percentage
-- ============================================================

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        SUM(oi.quantity * p.price) AS revenue
    FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY month
),

previous_sales AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly_sales
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        ((revenue - previous_revenue) / previous_revenue) * 100,
        2
    ) AS growth_percentage
FROM previous_sales
WHERE previous_revenue IS NOT NULL
ORDER BY month;


-- ============================================================
-- 5. Revenue percentage by category
-- ============================================================

WITH category_sales AS (
    SELECT
        p.category,
        SUM(oi.quantity * p.price) AS revenue
    FROM products AS p
    JOIN order_items AS oi
        ON p.product_id = oi.product_id
    GROUP BY p.category
),

total_sales AS (
    SELECT SUM(revenue) AS total_revenue
    FROM category_sales
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        (revenue / total_revenue) * 100,
        2
    ) AS percentage_of_total
FROM category_sales, total_sales
ORDER BY revenue DESC;


-- ============================================================
-- 6. Customers with more than 5 orders
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS number_of_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(o.order_id) > 5
ORDER BY number_of_orders DESC;


-- ============================================================
-- 7. Customers spending more than the average customer
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(oi.quantity * p.price) AS total_spent
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
)

SELECT
    customer_id,
    first_name,
    last_name,
    ROUND(total_spent, 2) AS total_spent
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spending
)
ORDER BY total_spent DESC;


-- ============================================================
-- 8. Products selling more than the average quantity
-- ============================================================

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold
    FROM products AS p
    JOIN order_items AS oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
)

SELECT
    product_id,
    product_name,
    units_sold
FROM product_sales
WHERE units_sold > (
    SELECT AVG(units_sold)
    FROM product_sales
)
ORDER BY units_sold DESC;


-- ============================================================
-- 9. Inventory value by product
-- ============================================================

SELECT
    product_id,
    product_name,
    category,
    price,
    stock,
    ROUND(price * stock, 2) AS inventory_value
FROM products
ORDER BY inventory_value DESC;


-- ============================================================
-- 10. Total inventory value
-- ============================================================

SELECT
    ROUND(SUM(price * stock), 2) AS total_inventory_value
FROM products;


-- ============================================================
-- 11. Low-stock products with inventory value
-- ============================================================

SELECT
    product_id,
    product_name,
    category,
    stock,
    price,
    ROUND(price * stock, 2) AS inventory_value
FROM products
WHERE stock < 30
ORDER BY stock ASC;


-- ============================================================
-- 12. Employee ranking by revenue
-- ============================================================

WITH employee_sales AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.department,
        SUM(oi.quantity * p.price) AS revenue
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
)

SELECT
    employee_id,
    first_name,
    last_name,
    department,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS employee_rank
FROM employee_sales
ORDER BY employee_rank;


-- ============================================================
-- 13. Revenue by employee department
-- ============================================================

SELECT
    e.department,
    COUNT(DISTINCT e.employee_id) AS employees,
    COUNT(DISTINCT o.order_id) AS orders_handled,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM employees AS e
JOIN orders AS o
    ON e.employee_id = o.employee_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY e.department
ORDER BY revenue DESC;


-- ============================================================
-- 14. Average quantity per order
-- ============================================================

SELECT
    ROUND(
        CAST(SUM(quantity) AS REAL) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_items_per_order
FROM order_items;


-- ============================================================
-- 15. Orders containing more than 10 items
-- ============================================================

SELECT
    order_id,
    SUM(quantity) AS total_items
FROM order_items
GROUP BY order_id
HAVING SUM(quantity) > 10
ORDER BY total_items DESC;


-- ============================================================
-- 16. Most popular product in each category
-- ============================================================

WITH product_sales AS (
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
),

ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category
            ORDER BY units_sold DESC
        ) AS category_rank
    FROM product_sales
)

SELECT
    category,
    product_name,
    units_sold
FROM ranked_products
WHERE category_rank = 1
ORDER BY category;


-- ============================================================
-- 17. Customers who never placed an order
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 18. Products that were never sold
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- ============================================================
-- 19. Top customer in each city
-- ============================================================

WITH customer_sales AS (
    SELECT
        c.city,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY
        c.city,
        c.customer_id,
        c.first_name,
        c.last_name
),

ranked_customers AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY city
            ORDER BY total_spent DESC
        ) AS city_rank
    FROM customer_sales
)

SELECT
    city,
    customer_id,
    first_name,
    last_name,
    ROUND(total_spent, 2) AS total_spent
FROM ranked_customers
WHERE city_rank = 1
ORDER BY city;


-- ============================================================
-- 20. Complete business summary
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM employees) AS total_employees,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT SUM(quantity) FROM order_items) AS total_units_sold,
    (
        SELECT ROUND(SUM(oi.quantity * p.price), 2)
        FROM order_items AS oi
        JOIN products AS p
            ON oi.product_id = p.product_id
    ) AS total_revenue;