import json
import urllib.parse
import boto3
from sqlalchemy import create_engine, text
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Extract environment variables
    db_user = os.environ['DB_USER']
    db_password = os.environ['DB_PASSWORD']
    db_host = os.environ['DB_HOST']
    db_name = os.environ['DB_NAME']
    
    # Extract bucket and key from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    # Create database url from environment variable, then create the engine
    DB_URL = f'postgresql+psycopg2://{db_user}:{db_password}@{db_host}:5432/{db_name}'
    global engine
    engine = create_engine(DB_URL)
    
    try:
        # Fetch the file from S3
        response = s3.get_object(Bucket=bucket, key=key)
        file_content = response['body'].read().decode('utf-8')
        
        # Parse the file content
        rows = file_content.splitlines()
        data = [row.split(',') for row in rows[1:]]
        
        # Insert into RDS
        insert_into_rds(data)
        
        return {
            'statusCode': 200,
            'body': f'Successfully processed {len(data)} rows'
        }
    except Exception as e:
        print(e)
        
def insert_into_rds(data):
    try:
        # Open a connection with database, and start a transaction
        with engine.begin() as connection:
            insert_query = """
            INSERT INTO staging_table (
                transaction_id,
                transaction_data,
                transaction_time,
                total_amount,
                payment_method,
                store_id,
                store_name,
                store_location,
                product_id,
                product_name,
                product_category,
                product_price,
                quantity_sold,
                customer_id,
                customer_age,
                customer_gender,
                customer_membership
            )
            VALUES (
                :col1,
                :col2,
                :col3,
                :col4,
                :col5,
                :col6,
                :col7,
                :col8,
                :col9,
                :col10,
                :col11,
                :col12,
                :col13,
                :col14,
                :col15,
                :col16,
                :col17
            )
            """
            for row in data:
                connection.execute(
                    text(insert_query),
                    {
                        "col1": row[0],
                        "col2": row[1],
                        "col3": row[2],
                        "col4": row[3],
                        "col5": row[4],
                        "col6": row[5],
                        "col7": row[6],
                        "col8": row[7],
                        "col9": row[8],
                        "col10": row[9],
                        "col11": row[10],
                        "col12": row[11],
                        "col13": row[12],
                        "col14": row[13],
                        "col15": row[14],
                        "col16": row[15],
                        "col17": row[16]
                    }
                )
                
            print(f'Inserted {len(data)} rows into the database')
    except Exception as e:
        print(e)