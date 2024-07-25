import mysql.connector
import json

# Read the JSON file
with open('data.json') as f:
    data = json.load(f)

# Convert data to JSON string
json_data = json.dumps(data)

# Connect to the database
conn = mysql.connector.connect(
    host="localhost",
    user="yourusername",
    password="yourpassword",
    database="yourdatabase"
)
cursor = conn.cursor()

# Call the stored procedure
cursor.callproc('InsertProductData', [json_data])

# Commit and close
conn.commit()
cursor.close()
conn.close()
