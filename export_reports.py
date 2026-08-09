import sqlite3
import pandas as pd
import os

# ============================================================
# PROJECT PATHS
# ============================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATABASE_PATH = os.path.join(
    BASE_DIR,
    "database",
    "retail.db"
)

REPORTS_DIR = os.path.join(
    BASE_DIR,
    "reports"
)

# Create reports folder if it doesn't exist
os.makedirs(REPORTS_DIR, exist_ok=True)


# ============================================================
# DATABASE CONNECTION
# ============================================================

connection = sqlite3.connect(DATABASE_PATH)

print("=" * 50)
print("       EXPORTING ANALYTICS REPORTS")
print("=" * 50)


# ============================================================
# 1. MONTHLY REVENUE
# ============================================================

query = """
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
"""

monthly_revenue = pd.read_sql_query(query, connection)

monthly_revenue.to_csv(
    os.path.join(REPORTS_DIR, "monthly_revenue.csv"),
    index=False
)

print("✅ monthly_revenue.csv exported")


# ============================================================
# 2. REVENUE BY CATEGORY
# ============================================================

query = """
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;
"""

category_sales = pd.read_sql_query(query, connection)

category_sales.to_csv(
    os.path.join(REPORTS_DIR, "category_sales.csv"),
    index=False
)

print("✅ category_sales.csv exported")


# ============================================================
# 3. TOP PRODUCTS
# ============================================================

query = """
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
ORDER BY revenue DESC
LIMIT 10;
"""

top_products = pd.read_sql_query(query, connection)

top_products.to_csv(
    os.path.join(REPORTS_DIR, "top_products.csv"),
    index=False
)

print("✅ top_products.csv exported")


# ============================================================
# 4. TOP CUSTOMERS
# ============================================================

query = """
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS orders,
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
"""

top_customers = pd.read_sql_query(query, connection)

top_customers.to_csv(
    os.path.join(REPORTS_DIR, "top_customers.csv"),
    index=False
)

print("✅ top_customers.csv exported")


# ============================================================
# 5. EMPLOYEE PERFORMANCE
# ============================================================

query = """
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    COUNT(DISTINCT o.order_id) AS orders_handled,
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
"""

employee_performance = pd.read_sql_query(query, connection)

employee_performance.to_csv(
    os.path.join(REPORTS_DIR, "employee_performance.csv"),
    index=False
)

print("✅ employee_performance.csv exported")


# ============================================================
# CLOSE DATABASE
# ============================================================

connection.close()

print("\n" + "=" * 50)
print("       REPORT EXPORT COMPLETED ✅")
print("=" * 50)
print("📁 Reports saved in:", REPORTS_DIR)