import sqlite3
import pandas as pd
import os

# Project directory
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Database path
DATABASE_PATH = os.path.join(BASE_DIR, "database", "retail.db")

# Dataset directory
DATASET_DIR = os.path.join(BASE_DIR, "datasets")

# Connect to SQLite
connection = sqlite3.connect(DATABASE_PATH)

print("🔗 Connected to retail.db")
print()

# CSV files and their corresponding database tables
files = {
    "customers.csv": "customers",
    "products.csv": "products",
    "employees.csv": "employees",
    "orders.csv": "orders",
    "order_items.csv": "order_items"
}

# Import each CSV
for filename, table_name in files.items():

    file_path = os.path.join(DATASET_DIR, filename)

    df = pd.read_csv(file_path)

    # Clear existing data
    connection.execute(f"DELETE FROM {table_name}")

    # Insert CSV data
    df.to_sql(
        table_name,
        connection,
        if_exists="append",
        index=False
    )

    print(f"✅ {filename} → {table_name} ({len(df)} rows)")

# Save changes
connection.commit()

print()
print("=" * 45)
print("       IMPORT COMPLETED")
print("=" * 45)

# Check number of rows
for table_name in files.values():

    result = connection.execute(
        f"SELECT COUNT(*) FROM {table_name}"
    ).fetchone()

    print(f"{table_name}: {result[0]} rows")

connection.close()

print("=" * 45)
print("🔒 Database connection closed")