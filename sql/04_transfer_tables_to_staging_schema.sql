-- 1. Copy tables from raw to staging with structure and data
SELECT * INTO stg.customers FROM raw.customers;
SELECT * INTO stg.geolocation FROM raw.geolocation;
SELECT * INTO stg.order_items FROM raw.order_items;
SELECT * INTO stg.order_payments FROM raw.order_payments;
SELECT * INTO stg.order_reviews FROM raw.order_reviews;
SELECT * INTO stg.orders FROM raw.orders;
SELECT * INTO stg.products FROM raw.products;
SELECT * INTO stg.sellers FROM raw.sellers;
SELECT * INTO stg.product_category_translation FROM raw.product_category_translation;

-- 2. Verify tables were copied into the staging schema
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
