import mysql.connector
import json

# Read and convert JSON file
with open('data.json') as f:
    json_data = json.dumps(json.load(f))

# Database connection parameters
db_config = {
    'host': 'localhost',
    'user': 'yourusername',
    'password': 'yourpassword',
    'database': 'yourdatabase'
}

try:
    # Connect to the database
    with mysql.connector.connect(**db_config) as conn:
        # Call the stored procedure
        conn.cmd_query(f"CALL InsertProducts('{json_data}')")

        # Commit changes
        conn.commit()

except mysql.connector.Error as err:
    print(f"Error: {err}")
