# ELT Pipeline
An ELT Pipeline written in Python and SQL, using AWS services: EC2, S3, Lambda, RDS. 

A Pipeline that mimics loading data (csv files) into a data lake, S3 here, and then get loaded using Lambda functions into a staging table in a postgres database on RDS, the database is equipped with a transformation function that gets triggered when new rows are inserted into the staging table, and transforms the data from the denormalized form it came in from the csv files into a normalized star schema model.

## EC2
The EC2 instance is only used here to generate the mock data and place it in an S3 bucket. It's not particularly essential to the pipeline as I can achieve the same thing with a script run on my local machine, but I use it to take advantage of the network infrastructure.

- I create the temporary instance manually through the AWS console, the free tier instance of type t3.micro does the job quite fine

- I automate the whole thing using a bash script in the instance user data.

- I attached an IAM role with Full Access to the designated S3 bucket.

- I went for the default settings for the most part here since it's so simple a job, Linux system, no EBS volume attached, but I didn't setup SSH keys since the whole thing is automated through the script.

- After the script runs and places all the data in the S3 bucket, I terminate the instance manually.

## S3
Just a simple S3 bucket to place the generated mock data.

## RDS
Since the project is supposed to be more OLTP-oriented, I chose RDS over other AWS database offerings like Aurora or Redshift which are more suited for higher workloads and OLAP work.
Note: I realize that at the scale of my data and the far too low number of connections and insert operations, the choice of database service will have a negligible effect on the performance. I might as well perform OLAP workload on the same database and it'll be fine.

- I created the database manually from the AWS console.

- I chose an m5.large instance for consistent processing power (not burstable credits) since this is a transactional database.

- After creating the database, I accessed the CLI through my terminal and executed the db_initiation.sql and db_transformation.sql files using the command `\i path/to/files`

- The initiation process included creating the tables (a staging table, and a fact & dimension tables) and establishing the relationship between them and their constraints.

- The transformation script included the function that takes the records from the staging table and puts them in the star schema, and the trigger on the staging table that triggers this function with every insert statement.

## Lambda
A simple lambda function to be triggered whenever a file gets places in a certain S3 bucket that takes the contents of that file and insert it in the database's staging table.

### Using Docker to package
One challenge I faced with setting this up was the dependencies, as I'm running a Mac OS while the lambda function runs in a Linux environment, one dependency in particular, the postgres engine the sqlalchemy uses `psycopg2` was not compatible between the two systems and caused issues when I packaged the function with its dependencies on my machine. To overcome this, I used Docker: I got the image amazon/aws-lambda-python:3.10 and ran a container, inside this container, I installed the dependencis I needed into a folder, zipped it, and then copied it to my machine and added the lambda_function.py file to it.
