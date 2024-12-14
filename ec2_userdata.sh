#!/bin/bash
# Update the instance and install necessary tools
yum update -y
yum install -y python3 aws-cli python3-pip

# Install Python libraries
pip3 install pandas faker boto3

# Generate and upload mock data
BUCKET_NAME="mock-data-bucket-sh-first"

# Create the S3 bucket (if it doesn't exist)
aws s3 mb s3://$BUCKET_NAME --region eu-north-1

# Python script for generating mock data
cat << EOF > generate_mock_data.py
import pandas as pd
import numpy as np
from faker import Faker
from random import randint, choice
import boto3
import time

# Initialize Faker
faker = Faker()

# Generate mock data
def generate_data(start_id, num_rows):
    data = {
        "Transaction_ID": [f"TXN{str(i).zfill(6)}" for i in range(start_id, start_id + num_rows)],
        "Transaction_Date": [faker.date_between(start_date="-5y", end_date="today") for _ in range(num_rows)],
        "Transaction_Time": [faker.time() for _ in range(num_rows)],
        "Total_Amount": [round(randint(5, 500) * 1.05, 2) for _ in range(num_rows)],
        "Payment_Method": [choice(["Cash", "Credit Card", "Debit Card", "Mobile Payment"]) for _ in range(num_rows)],
        "Store_ID": [randint(1, 100) for _ in range(num_rows)],
        "Store_Name": [f"Store_{randint(1, 100)}" for _ in range(num_rows)],
        "Store_Location": [f"{faker.city()}- {faker.state()}" for _ in range(num_rows)],
        "Product_ID": [randint(1, 1000) for _ in range(num_rows)],
        "Product_Name": [faker.word().capitalize() for _ in range(num_rows)],
        "Product_Category": [choice(["Electronics", "Clothing", "Groceries", "Furniture", "Books"]) for _ in range(num_rows)],
        "Product_Price": [round(randint(5, 500) * 1.05, 2) for _ in range(num_rows)],
        "Quantity_Sold": [randint(1, 10) for _ in range(num_rows)],
        "Customer_ID": [randint(1, 5000) for _ in range(num_rows)],
        "Customer_Age": [randint(18, 70) for _ in range(num_rows)],
        "Customer_Gender": [choice(["Male", "Female"]) for _ in range(num_rows)],
        "Customer_Membership": [choice(["Regular", "Gold", "Platinum"]) for _ in range(num_rows)],
    }
    return pd.DataFrame(data)

# Save to S3
def save_to_s3(dataframe, bucket_name, file_name):
    s3 = boto3.client('s3')
    csv_buffer = dataframe.to_csv(index=False)
    s3.put_object(Bucket=bucket_name, Key=file_name, Body=csv_buffer)
    print(f"File {file_name} uploaded to S3 bucket {bucket_name}.")

# Main script
if __name__ == "__main__":
    total_rows = 500000
    rows_per_file = 2000
    num_files = total_rows // rows_per_file
    bucket_name = "mock-data-bucket-sh-first"

    # Track the starting ID
    start_id = 1

    for i in range(num_files):
        # Generate data for this batch
        mock_data = generate_data(start_id, rows_per_file)
        
        # Generate a unique file name for each chunk
        file_name = f"mock_retail_data_part_{i+1}.csv"
        save_to_s3(mock_data, bucket_name, file_name)
        
        # Update the starting ID for the next batch
        start_id += rows_per_file
        
        # Wait for 20 seconds before uploading the next file
        time.sleep(20)
EOF

# Run the Python script
python3 generate_mock_data.py
