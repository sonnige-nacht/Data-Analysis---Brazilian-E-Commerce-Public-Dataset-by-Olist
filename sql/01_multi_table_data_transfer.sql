-- 1. Enable postgres_fdw
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Create Source Database Connection
CREATE SERVER source_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'localhost',
    port '5432',
    dbname 'olist_db'
);

-- 3. Configure User Mapping
CREATE USER MAPPING FOR CURRENT_USER
SERVER source_server
OPTIONS (
    user 'iman',
    password '1234'
);

-- 4. Create Foreign Schema
CREATE SCHEMA foreign_schema;

-- 5. Import Multiple Source Tables
IMPORT FOREIGN SCHEMA public
LIMIT TO (
    customers,
    geolocation,
    order_items,
	order_payments,
	order_reviews,
	orders,
	product_category_translation,
	products,
	sellers
)
FROM SERVER source_server
INTO foreign_schema;

-- 6. Transfer Table Data
INSERT INTO raw.customers SELECT * FROM foreign_schema.customers;
INSERT INTO raw.geolocation SELECT * FROM foreign_schema.geolocation;
INSERT INTO raw.order_items SELECT * FROM foreign_schema.order_items;
INSERT INTO raw.order_payments SELECT * FROM foreign_schema.order_payments;
INSERT INTO raw.order_reviews SELECT * FROM foreign_schema.order_reviews;
INSERT INTO raw.orders SELECT * FROM foreign_schema.orders;
INSERT INTO raw.product_category_translation SELECT * FROM foreign_schema.product_category_translation;
INSERT INTO raw.products SELECT * FROM foreign_schema.products;
INSERT INTO raw.sellers SELECT * FROM foreign_schema.sellers;