
-- SQL RETAIL ANALYTICS
-- BASIC SQL QUERIES


SELECT *
FROM customers;



SELECT *
FROM customers
LIMIT 10;



SELECT COUNT(*) AS total_customers
FROM customers;




SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city
FROM customers
ORDER BY last_name ASC;



SELECT *
FROM customers
WHERE first_name LIKE 'A%';




SELECT *
FROM products;




SELECT COUNT(*) AS total_products
FROM products;



SELECT *
FROM products
WHERE price > 100
ORDER BY price DESC;




SELECT
    product_id,
    product_name,
    category,
    price,
    stock
FROM products
ORDER BY price ASC
LIMIT 10;



SELECT
    product_id,
    product_name,
    category,
    price,
    stock
FROM products
ORDER BY price DESC
LIMIT 10;



SELECT
    ROUND(AVG(price), 2) AS average_product_price
FROM products;




SELECT *
FROM products
WHERE stock < 30
ORDER BY stock ASC;




SELECT
    category,
    COUNT(*) AS number_of_products
FROM products
GROUP BY category
ORDER BY number_of_products DESC;




SELECT
    category,
    ROUND(AVG(price), 2) AS average_price
FROM products
GROUP BY category
ORDER BY average_price DESC;



SELECT *
FROM employees;




SELECT
    department,
    COUNT(*) AS number_of_employees
FROM employees
GROUP BY department
ORDER BY number_of_employees DESC;




SELECT
    COUNT(*) AS total_orders
FROM orders;




SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 10;




SELECT
    customer_id,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY customer_id
ORDER BY number_of_orders DESC;




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
ORDER BY number_of_orders DESC
LIMIT 10;