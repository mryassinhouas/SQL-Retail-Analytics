from faker import Faker
import pandas as pd
import random
import os
from datetime import datetime, timedelta

fake = Faker()

# Project directories
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASET_DIR = os.path.join(BASE_DIR, "datasets")

os.makedirs(DATASET_DIR, exist_ok=True)

# ============================================================
# 1. CUSTOMERS
# ============================================================

customers = []

for i in range(1, 101):
    customers.append({
        "customer_id": i,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.email(),
        "city": fake.city()
    })

pd.DataFrame(customers).to_csv(
    os.path.join(DATASET_DIR, "customers.csv"),
    index=False
)

print("✅ customers.csv created successfully!")


# ============================================================
# 2. PRODUCTS
# ============================================================

product_templates = [
    ("Laptop Pro", "Electronics", 1200, 2500),
    ("Wireless Mouse", "Electronics", 20, 100),
    ("Mechanical Keyboard", "Electronics", 50, 180),
    ("Gaming Headset", "Electronics", 40, 200),
    ("27 Inch Monitor", "Electronics", 180, 500),
    ("USB-C Hub", "Electronics", 25, 100),
    ("External SSD", "Electronics", 70, 250),
    ("Wireless Earbuds", "Electronics", 40, 220),
    ("Smartphone", "Electronics", 500, 1500),
    ("Tablet", "Electronics", 250, 900),

    ("Office Chair", "Furniture", 100, 400),
    ("Office Desk", "Furniture", 150, 600),
    ("Bookshelf", "Furniture", 80, 300),
    ("Standing Desk", "Furniture", 250, 800),
    ("Desk Lamp", "Furniture", 25, 120),

    ("Coffee Maker", "Home Appliances", 50, 250),
    ("Air Fryer", "Home Appliances", 60, 250),
    ("Blender", "Home Appliances", 40, 180),
    ("Microwave Oven", "Home Appliances", 100, 400),
    ("Electric Kettle", "Home Appliances", 25, 100),

    ("Backpack", "Accessories", 30, 150),
    ("Travel Bag", "Accessories", 40, 200),
    ("Wallet", "Accessories", 20, 100),
    ("Watch", "Accessories", 80, 500),
    ("Sunglasses", "Accessories", 30, 200),

    ("Running Shoes", "Sports", 50, 180),
    ("Football", "Sports", 20, 80),
    ("Basketball", "Sports", 25, 100),
    ("Yoga Mat", "Sports", 20, 80),
    ("Fitness Tracker", "Sports", 50, 250),

    ("Notebook", "Stationery", 5, 20),
    ("Pen Set", "Stationery", 3, 15),
    ("Desk Organizer", "Stationery", 10, 40),
    ("Calculator", "Stationery", 10, 50),
    ("Planner", "Stationery", 8, 30),

    ("Coffee Beans", "Food", 10, 40),
    ("Green Tea", "Food", 5, 25),
    ("Chocolate Box", "Food", 8, 35),
    ("Protein Bar Pack", "Food", 10, 45),
    ("Snack Box", "Food", 12, 50),

    ("LED Light Strip", "Home Decor", 15, 70),
    ("Wall Clock", "Home Decor", 20, 100),
    ("Picture Frame", "Home Decor", 10, 60),
    ("Candle Set", "Home Decor", 10, 50),
    ("Plant Pot", "Home Decor", 8, 40),

    ("Bluetooth Speaker", "Audio", 40, 250),
    ("Soundbar", "Audio", 100, 600),
    ("Studio Microphone", "Audio", 80, 400),
    ("Portable Radio", "Audio", 30, 150),
    ("Noise Cancelling Headphones", "Audio", 100, 500)
]

products = []

for i, (name, category, min_price, max_price) in enumerate(product_templates, start=1):
    products.append({
        "product_id": i,
        "product_name": name,
        "category": category,
        "price": round(random.uniform(min_price, max_price), 2),
        "stock": random.randint(10, 200)
    })

pd.DataFrame(products).to_csv(
    os.path.join(DATASET_DIR, "products.csv"),
    index=False
)

print("✅ products.csv created successfully!")


# ============================================================
# 3. EMPLOYEES
# ============================================================

departments = [
    "Sales",
    "Sales",
    "Sales",
    "Marketing",
    "Customer Service",
    "Customer Service",
    "IT",
    "IT",
    "Finance",
    "Finance",
    "Human Resources",
    "Logistics",
    "Logistics",
    "Management",
    "Management"
]

employees = []

for i in range(1, 16):
    employees.append({
        "employee_id": i,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "department": departments[i - 1]
    })

pd.DataFrame(employees).to_csv(
    os.path.join(DATASET_DIR, "employees.csv"),
    index=False
)

print("✅ employees.csv created successfully!")


# ============================================================
# 4. ORDERS
# ============================================================

orders = []

start_date = datetime(2025, 1, 1)

for i in range(1, 501):
    random_days = random.randint(0, 364)
    order_date = start_date + timedelta(days=random_days)

    orders.append({
        "order_id": i,
        "customer_id": random.randint(1, 100),
        "employee_id": random.randint(1, 15),
        "order_date": order_date.strftime("%Y-%m-%d")
    })

pd.DataFrame(orders).to_csv(
    os.path.join(DATASET_DIR, "orders.csv"),
    index=False
)

print("✅ orders.csv created successfully!")


# ============================================================
# 5. ORDER ITEMS
# ============================================================

order_items = []

item_id = 1

for order_id in range(1, 501):

    # Each order contains exactly 3 different products
    selected_products = random.sample(range(1, 51), 3)

    for product_id in selected_products:

        order_items.append({
            "item_id": item_id,
            "order_id": order_id,
            "product_id": product_id,
            "quantity": random.randint(1, 5)
        })

        item_id += 1

pd.DataFrame(order_items).to_csv(
    os.path.join(DATASET_DIR, "order_items.csv"),
    index=False
)

print("✅ order_items.csv created successfully!")


# ============================================================
# SUMMARY
# ============================================================

print("\n" + "=" * 45)
print("       DATA GENERATION COMPLETED")
print("=" * 45)

print(f"Customers:    {len(customers)}")
print(f"Products:     {len(products)}")
print(f"Employees:    {len(employees)}")
print(f"Orders:       {len(orders)}")
print(f"Order Items:  {len(order_items)}")

print("=" * 45)
print("📁 All CSV files saved in datasets/")
