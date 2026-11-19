
-- 1. Create Dimensions

-- dim_customers
CREATE TABLE dw.dim_customers (
    customer_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id TEXT NOT NULL,
    customer_unique_id TEXT NULL,
    customer_zip_code_prefix BIGINT NULL,
    customer_city TEXT NULL,
    customer_state TEXT NULL
);

-- prevent to be filled with a same customer_id in future
CREATE UNIQUE INDEX ux_dim_customers_customer_id
ON dw.dim_customers(customer_id);

-- load data to dim_customers
INSERT INTO dw.dim_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
FROM stg.customers c
ON CONFLICT (customer_id) DO NOTHING;


-- ---------------------------------------------------------- --


-- dim_sellers
CREATE TABLE dw.dim_sellers (
    seller_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id TEXT NOT NULL,
    seller_zip_code_prefix BIGINT NULL,
    seller_city TEXT NULL,
    seller_state TEXT NULL
);

-- prevent to be filled with a same seller_id in future
CREATE UNIQUE INDEX ux_dim_sellers_seller_id
ON dw.dim_sellers(seller_id);

-- load data to dim_sellers
INSERT INTO dw.dim_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
FROM stg.sellers s
ON CONFLICT (seller_id) DO NOTHING;


-- ---------------------------------------------------------- --


-- dim_products
CREATE TABLE dw.dim_products (
    product_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id TEXT NOT NULL,
    product_category_name TEXT NULL,
    product_category_name_english TEXT NULL,
    product_category_name_persian TEXT NULL,
    product_name_lenght DOUBLE PRECISION NULL,
    product_description_lenght DOUBLE PRECISION NULL,
    product_photos_qty DOUBLE PRECISION NULL,
    product_weight_g DOUBLE PRECISION NULL,
    product_length_cm DOUBLE PRECISION NULL,
    product_height_cm DOUBLE PRECISION NULL,
    product_width_cm DOUBLE PRECISION NULL
);

-- prevent to be filled with a same product_id in future
CREATE UNIQUE INDEX ux_dim_products_product_id
ON dw.dim_products(product_id);

-- load data to dim_products
INSERT INTO dw.dim_products (
    product_id,
    product_category_name,
    product_category_name_english,
    product_category_name_persian,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    t.product_category_name_persian,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM stg.products p
LEFT JOIN stg.product_category_translation t
    ON p.product_category_name = t.product_category_name
ON CONFLICT (product_id) DO NOTHING;


-- ---------------------------------------------------------- --


-- dim_orders
CREATE TABLE dw.dim_orders (
    order_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id TEXT NOT NULL,
    customer_id TEXT NULL,
    order_status TEXT NULL,
    order_purchase_timestamp TIMESTAMP NULL,
    order_approved_at TIMESTAMP NULL,
    order_delivered_carrier_date TIMESTAMP NULL,
    order_delivered_customer_date TIMESTAMP NULL,
    order_estimated_delivery_date TIMESTAMP NULL
);

-- prevent to be filled with a same order_id in future
CREATE UNIQUE INDEX ux_dim_orders_order_id
ON dw.dim_orders(order_id);

-- load data to dim_orders
INSERT INTO dw.dim_orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
FROM stg.orders o
ON CONFLICT (order_id) DO NOTHING;


-- ---------------------------------------------------------- --


-- 2. Create Facts

-- fact_order_items
CREATE TABLE dw.fact_order_items (
    fact_order_items_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id TEXT NOT NULL,
    order_item_id BIGINT NOT NULL,

    customer_key INT NULL,
    seller_key INT NULL,
    product_key INT NULL,

    order_status TEXT NULL,

    order_purchase_timestamp TIMESTAMP NULL,
    order_approved_at TIMESTAMP NULL,
    order_delivered_carrier_date TIMESTAMP NULL,
    order_delivered_customer_date TIMESTAMP NULL,
    order_estimated_delivery_date TIMESTAMP NULL,
    shipping_limit_date TIMESTAMP NULL,

    price DOUBLE PRECISION NULL,
    freight_value DOUBLE PRECISION NULL
);

CREATE UNIQUE INDEX ux_fact_order_items_order_id_order_item_id
ON dw.fact_order_items(order_id, order_item_id);

INSERT INTO dw.fact_order_items (
    order_id,
    order_item_id,

    customer_key,
    seller_key,
    product_key,

    order_status,

    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    shipping_limit_date,

    price,
    freight_value
)
SELECT
    oi.order_id,
    oi.order_item_id,

    dc.customer_key,
    ds.seller_key,
    dp.product_key,

    o.order_status,

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.shipping_limit_date,

    oi.price,
    oi.freight_value
FROM stg.order_items AS oi
INNER JOIN stg.orders AS o
    ON oi.order_id = o.order_id

LEFT JOIN dw.dim_customers AS dc
    ON o.customer_id = dc.customer_id

LEFT JOIN dw.dim_sellers AS ds
    ON oi.seller_id = ds.seller_id

LEFT JOIN dw.dim_products AS dp
    ON oi.product_id = dp.product_id

ON CONFLICT (order_id, order_item_id) DO NOTHING;


-- ---------------------------------------------------------- --


-- fact_order_payments
CREATE TABLE dw.fact_order_payments (
    fact_order_payments_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id TEXT NOT NULL,
    payment_sequential BIGINT NOT NULL,

    customer_key INT NULL,
    order_purchase_timestamp TIMESTAMP NULL,

    payment_type TEXT NULL,
    payment_installments BIGINT NULL,
    payment_value DOUBLE PRECISION NULL
);

CREATE UNIQUE INDEX ux_fact_order_payments_order_id_payment_sequential
ON dw.fact_order_payments(order_id, payment_sequential);

INSERT INTO dw.fact_order_payments (
    order_id,
    payment_sequential,

    customer_key,

    order_purchase_timestamp,

    payment_type,
    payment_installments,
    payment_value
)
SELECT
    op.order_id,
    op.payment_sequential,

    dc.customer_key,

    o.order_purchase_timestamp,

    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM stg.order_payments AS op
LEFT JOIN stg.orders AS o
    ON op.order_id = o.order_id

LEFT JOIN dw.dim_customers AS dc
    ON o.customer_id = dc.customer_id

ON CONFLICT (order_id, payment_sequential) DO NOTHING;


-- ---------------------------------------------------------- --


-- fact_order_reviews
CREATE TABLE dw.fact_order_reviews (
    fact_order_reviews_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    review_id TEXT NOT NULL,
    order_id TEXT NOT NULL,

    customer_key INT NULL,

    review_creation_date TIMESTAMP NULL,
    review_answer_timestamp TIMESTAMP NULL,

    review_score BIGINT NULL
);

CREATE UNIQUE INDEX ux_fact_order_reviews_review_id_order_id
ON dw.fact_order_reviews(review_id, order_id);

INSERT INTO dw.fact_order_reviews (
    review_id,
    order_id,

    customer_key,

    review_creation_date,
    review_answer_timestamp,

    review_score
)
SELECT
    r.review_id,
    r.order_id,

    dc.customer_key,

    r.review_creation_date,
    r.review_answer_timestamp,

    r.review_score
FROM stg.order_reviews AS r
LEFT JOIN stg.orders AS o
    ON r.order_id = o.order_id

LEFT JOIN dw.dim_customers AS dc
    ON o.customer_id = dc.customer_id

ON CONFLICT (review_id, order_id) DO NOTHING;