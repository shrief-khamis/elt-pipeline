CREATE OR REPLACE FUNCTION schema_transform()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO dim_stores (store_id, store_name, store_city, store_state)
    SELECT DISTINCT store_id,
        store_name,
        SPLIT_PART(store_location, '-', 1) AS store_city,
        TRIM(SPLIT_PART(store_location, '-', 2)) AS store_state
    FROM staging_table
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_stores WHERE dim_stores.store_id = staging_table.store_id
    );


    INSERT INTO dim_products (product_id, product_name, product_category, product_price)
    SELECT DISTINCT product_id, product_name, product_category, product_price
    FROM staging_table
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_products WHERE dim_products.product_id = staging_table.product_id
    );


    INSERT INTO dim_customers (customer_id, customer_age, customer_gender, customer_membership)
    SELECT DISTINCT customer_id, customer_age, customer_gender, customer_membership
    FROM staging_table
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customers WHERE dim_customers.customer_id = staging_table.customer_id
    );


    INSERT INTO facts (
        transaction_id,
        transaction_date,
        transaction_time,
        store_id,
        product_id,
        customer_id,
        quantity_sold,
        total_amount
    )
    SELECT 
        st.transaction_id,
        st.transaction_date,
        st.transaction_time,
        st.store_id,
        st.product_id,
        st.customer_id,
        st.quantity_sold,
        st.total_amount
    FROM staging_table AS st
    WHERE NOT EXISTS (
        SELECT 1 FROM facts WHERE facts.transaction_id = st.transaction_id
    );

    RETURN NEW;
END;
$$;


CREATE TRIGGER schema_transform_trigger
AFTER INSERT ON staging_table
FOR EACH STATEMENT
EXECUTE FUNCTION schema_transform();
