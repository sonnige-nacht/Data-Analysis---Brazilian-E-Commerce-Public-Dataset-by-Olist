-- 1. Create schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

-- 2. Insert all tables from raw to stg
INSERT INTO stg.customers SELECT * FROM raw.customers;
INSERT INTO stg.geolocation SELECT * FROM raw.geolocation;
INSERT INTO stg.order_items SELECT * FROM raw.order_items;
INSERT INTO stg.order_payments SELECT * FROM raw.order_payments;
INSERT INTO stg.order_reviews SELECT * FROM raw.order_reviews;
INSERT INTO stg.orders SELECT * FROM raw.orders;
INSERT INTO stg.product_category_translation SELECT * FROM raw.product_category_translation;
INSERT INTO stg.products SELECT * FROM raw.products;
INSERT INTO stg.sellers SELECT * FROM raw.sellers;

-- 3. Verify
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'stg'
ORDER BY TABLE_NAME;