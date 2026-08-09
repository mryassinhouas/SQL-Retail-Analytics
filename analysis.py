import sqlite3
import pandas as pd
import os

# ============================================================
# DATABASE CONNECTION
# ============================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATABASE_PATH = os.path.join(
    BASE_DIR,
    "database",
    "retail.db"
)

connection = sqlite3.connect(DATABASE_PATH)

print("=" * 50)
print("       RETAIL DATA ANALYSIS")
print("=" * 50)


# ============================================================
# 1. TOTAL REVENUE
# ============================================================

query = """
SELECT
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;
"""

revenue = pd.read_sql_query(query, connection)

print("\n💰 TOTAL REVENUE")
print(revenue)


# ============================================================
# 2. TOTAL ORDERS
# ============================================================

query = """
SELECT COUNT(*) AS total_orders
FROM orders;
"""

orders = pd.read_sql_query(query, connection)

print("\n🛒 TOTAL ORDERS")
print(orders)


# ============================================================
# 3. TOTAL PRODUCTS SOLD
# ============================================================

query = """
SELECT SUM(quantity) AS total_units_sold
FROM order_items;
"""

units = pd.read_sql_query(query, connection)

print("\n📦 TOTAL UNITS SOLD")
print(units)


# ============================================================
# 4. TOP 10 PRODUCTS
# ============================================================

query = """
SELECT
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

print("\n🏆 TOP 10 PRODUCTS")
print(top_products.to_string(index=False))


# ============================================================
# 5. TOP 10 CUSTOMERS
# ============================================================

query = """
SELECT
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

print("\n👑 TOP 10 CUSTOMERS")
print(top_customers.to_string(index=False))


# ============================================================
# 6. REVENUE BY CATEGORY
# ============================================================

query = """
SELECT
    p.category,
    ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;
"""

category_sales = pd.read_sql_query(query, connection)

print("\n🏷️ REVENUE BY CATEGORY")
print(category_sales.to_string(index=False))


# ============================================================
# 7. MONTHLY REVENUE
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

monthly_sales = pd.read_sql_query(query, connection)

print("\n📈 MONTHLY REVENUE")
print(monthly_sales.to_string(index=False))


# ============================================================
# CLOSE DATABASE
# ============================================================

connection.close()

print("\n" + "=" * 50)
print("       ANALYSIS COMPLETED ✅")
print("=" * 50)


import matplotlib.pyplot as plt

# Create images folder
images_dir = os.path.join(BASE_DIR, "images")
os.makedirs(images_dir, exist_ok=True)

# -------------------------------
# Revenue by Category
# -------------------------------

plt.figure(figsize=(10, 6))
plt.bar(category_sales["category"], category_sales["revenue"])
plt.title("Revenue by Category")
plt.xlabel("Category")
plt.ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(os.path.join(images_dir, "revenue_by_category.png"))
plt.close()


# -------------------------------
# Monthly Revenue
# -------------------------------

plt.figure(figsize=(10, 6))
plt.plot(monthly_sales["month"], monthly_sales["revenue"], marker="o")
plt.title("Monthly Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(os.path.join(images_dir, "monthly_revenue.png"))
plt.close()


# -------------------------------
# Top 10 Products
# -------------------------------

plt.figure(figsize=(10, 6))
plt.barh(
    top_products["product_name"],
    top_products["revenue"]
)
plt.title("Top 10 Products by Revenue")
plt.xlabel("Revenue")
plt.ylabel("Product")
plt.gca().invert_yaxis()
plt.tight_layout()
plt.savefig(os.path.join(images_dir, "top_products.png"))
plt.close()


# -------------------------------
# Top 10 Customers
# -------------------------------

plt.figure(figsize=(10, 6))
names = (
    top_customers["first_name"]
    + " "
    + top_customers["last_name"]
)

plt.barh(names, top_customers["total_spent"])
plt.title("Top 10 Customers by Spending")
plt.xlabel("Total Spent")
plt.ylabel("Customer")
plt.gca().invert_yaxis()
plt.tight_layout()
plt.savefig(os.path.join(images_dir, "top_customers.png"))
plt.close()

print("\n📊 CHARTS CREATED SUCCESSFULLY!")
print("📁 Check the images/ folder.")