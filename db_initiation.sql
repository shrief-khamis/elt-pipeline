CREATE TABLE IF NOT EXISTS staging_table (
    transaction_id TEXT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,
    payment_method TEXT NOT NULL,
    store_id SMALLINT NOT NULL,
    store_name VARCHAR(16) NOT NULL,
    store_location TEXT NOT NULL,
    product_id INT NOT NULL,
    product_name TEXT NOT NULL,
    product_category TEXT,
    product_price NUMERIC(15,2) NOT NULL,
    quantity_sold SMALLINT NOT NULL,
    customer_id INT,
    customer_age SMALLINT,
    customer_gender VARCHAR(6),
    customer_membership VARCHAR(8)
);


CREATE TABLE IF NOT EXISTS dim_stores (
    store_id SMALLINT PRIMARY KEY,
    store_name VARCHAR(16),
    store_city TEXT,
    store_state TEXT
);

CREATE TABLE IF NOT EXISTS dim_products (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    product_category TEXT,
    product_price NUMERIC(15,2)
);

CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id INT PRIMARY KEY,
    customer_age SMALLINT,
    customer_gender VARCHAR(6),
    customer_membership VARCHAR(8)
);

CREATE TABLE IF NOT EXISTS facts (
    transaction_id TEXT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    store_id SMALLINT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    quantity_sold SMALLINT NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,

    CONSTRAINT fk_facts_store FOREIGN KEY (store_id)
        REFERENCES dim_stores(store_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_facts_product FOREIGN KEY (product_id)
        REFERENCES dim_products(product_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_facts_customer FOREIGN KEY (customer_id)
        REFERENCES dim_customers(customer_id)
        ON DELETE NO ACTION
);