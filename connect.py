import sqlite3
import os

# Get the project directory
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Path to the SQLite database
DATABASE_PATH = os.path.join(
    BASE_DIR,
    "database",
    "retail.db"
)

# Connect to database
connection = sqlite3.connect(DATABASE_PATH)

print("✅ Successfully connected to retail.db")

# Test the connection
cursor = connection.cursor()

cursor.execute("SELECT COUNT(*) FROM customers")
customer_count = cursor.fetchone()[0]

print(f"👥 Customers in database: {customer_count}")

# Close connection
connection.close()

print("🔒 Database connection closed")