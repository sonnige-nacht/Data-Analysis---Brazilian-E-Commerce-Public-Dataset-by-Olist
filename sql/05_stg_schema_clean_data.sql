-- Overview on all tables --
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'stg'
ORDER BY table_name, ordinal_position;


-- 1. CONVERT TEXT COLUMNS TO TIMESTAMP

-- order_items
ALTER TABLE stg.order_items
ALTER COLUMN shipping_limit_date TYPE TIMESTAMP
USING NULLIF(TRIM(shipping_limit_date), '')::TIMESTAMP;


-- orders
ALTER TABLE stg.orders
ALTER COLUMN order_purchase_timestamp TYPE TIMESTAMP
USING NULLIF(TRIM(order_purchase_timestamp), '')::TIMESTAMP;

ALTER TABLE stg.orders
ALTER COLUMN order_approved_at TYPE TIMESTAMP
USING NULLIF(TRIM(order_approved_at), '')::TIMESTAMP;

ALTER TABLE stg.orders
ALTER COLUMN order_delivered_carrier_date TYPE TIMESTAMP
USING NULLIF(TRIM(order_delivered_carrier_date), '')::TIMESTAMP;

ALTER TABLE stg.orders
ALTER COLUMN order_delivered_customer_date TYPE TIMESTAMP
USING NULLIF(TRIM(order_delivered_customer_date), '')::TIMESTAMP;

ALTER TABLE stg.orders
ALTER COLUMN order_estimated_delivery_date TYPE TIMESTAMP
USING NULLIF(TRIM(order_estimated_delivery_date), '')::TIMESTAMP;


-- order_reviews
ALTER TABLE stg.order_reviews
ALTER COLUMN review_creation_date TYPE TIMESTAMP
USING NULLIF(TRIM(review_creation_date), '')::TIMESTAMP;

ALTER TABLE stg.order_reviews
ALTER COLUMN review_answer_timestamp TYPE TIMESTAMP
USING NULLIF(TRIM(review_answer_timestamp), '')::TIMESTAMP;


-- 2. Drop useless columns

-- order_reviews
ALTER TABLE stg.order_reviews
DROP COLUMN IF EXISTS review_comment_title,
DROP COLUMN IF EXISTS review_comment_message;


-- 3. Drop duplicated rows

-- geolocation

-- 3.1 See there are many duplicated rows
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM stg.geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- 3.2 Drop the duplicated
WITH DuplicateRows AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY
                geolocation_zip_code_prefix,
                geolocation_lat,
                geolocation_lng,
                geolocation_city,
                geolocation_state
            ORDER BY ctid
        ) AS rn
    FROM stg.geolocation
)

DELETE FROM stg.geolocation
WHERE ctid IN (
    SELECT ctid
    FROM DuplicateRows
    WHERE rn > 1
);

-- 3.3 see the final total_rows of the table
SELECT COUNT(*) AS total_rows
FROM stg.geolocation;

-- 3.4 Add Persian Translation for Product Categories

ALTER TABLE stg.product_category_translation
ADD COLUMN IF NOT EXISTS product_category_name_persian TEXT;

UPDATE stg.product_category_translation
SET product_category_name_persian =
    CASE product_category_name_english
        WHEN 'health_beauty' THEN 'سلامت و زیبایی'
        WHEN 'computers_accessories' THEN 'کامپیوتر و لوازم جانبی'
        WHEN 'auto' THEN 'خودرو'
        WHEN 'bed_bath_table' THEN 'تختخواب، حمام و میز'
        WHEN 'furniture_decor' THEN 'مبلمان و دکوراسیون'
        WHEN 'sports_leisure' THEN 'ورزش و تفریح'
        WHEN 'perfumery' THEN 'عطر و ادکلن'
        WHEN 'housewares' THEN 'لوازم خانگی'
        WHEN 'telephony' THEN 'تلفن و لوازم جانبی'
        WHEN 'watches_gifts' THEN 'ساعت و هدایا'
        WHEN 'food_drink' THEN 'مواد غذایی و نوشیدنی'
        WHEN 'baby' THEN 'کودک و نوزاد'
        WHEN 'stationery' THEN 'لوازم‌التحریر'
        WHEN 'tablets_printing_image' THEN 'تبلت و تجهیزات چاپ و تصویر'
        WHEN 'toys' THEN 'اسباب‌بازی'
        WHEN 'fixed_telephony' THEN 'تلفن ثابت'
        WHEN 'garden_tools' THEN 'ابزار باغبانی'
        WHEN 'fashion_bags_accessories' THEN 'کیف و لوازم جانبی مد'
        WHEN 'small_appliances' THEN 'لوازم خانگی کوچک'
        WHEN 'consoles_games' THEN 'کنسول و بازی'
        WHEN 'audio' THEN 'تجهیزات صوتی'
        WHEN 'fashion_shoes' THEN 'کفش'
        WHEN 'cool_stuff' THEN 'محصولات جذاب و متنوع'
        WHEN 'luggage_accessories' THEN 'چمدان و لوازم سفر'
        WHEN 'air_conditioning' THEN 'تهویه مطبوع'
        WHEN 'construction_tools_construction' THEN 'ابزار و تجهیزات ساختمانی'
        WHEN 'kitchen_dining_laundry_garden_furniture' THEN 'آشپزخانه، پذیرایی، لباسشویی و مبلمان باغ'
        WHEN 'costruction_tools_garden' THEN 'ابزار باغبانی'
        WHEN 'fashion_male_clothing' THEN 'پوشاک مردانه'
        WHEN 'pet_shop' THEN 'لوازم حیوانات خانگی'
        WHEN 'office_furniture' THEN 'مبلمان اداری'
        WHEN 'market_place' THEN 'بازار'
        WHEN 'electronics' THEN 'لوازم الکترونیکی'
        WHEN 'home_appliances' THEN 'لوازم خانگی'
        WHEN 'party_supplies' THEN 'لوازم جشن و مهمانی'
        WHEN 'home_confort' THEN 'لوازم راحتی منزل'
        WHEN 'costruction_tools_tools' THEN 'ابزار ساختمانی'
        WHEN 'agro_industry_and_commerce' THEN 'کشاورزی، صنعت و تجارت'
        WHEN 'furniture_mattress_and_upholstery' THEN 'مبلمان، تشک و روکش'
        WHEN 'books_technical' THEN 'کتاب‌های فنی'
        WHEN 'home_construction' THEN 'ساخت و ساز منزل'
        WHEN 'musical_instruments' THEN 'آلات موسیقی'
        WHEN 'furniture_living_room' THEN 'مبلمان اتاق نشیمن'
        WHEN 'construction_tools_lights' THEN 'چراغ و تجهیزات روشنایی ساختمانی'
        WHEN 'industry_commerce_and_business' THEN 'صنعت، تجارت و کسب‌وکار'
        WHEN 'food' THEN 'مواد غذایی'
        WHEN 'art' THEN 'هنر'
        WHEN 'furniture_bedroom' THEN 'مبلمان اتاق خواب'
        WHEN 'books_general_interest' THEN 'کتاب‌های عمومی'
        WHEN 'construction_tools_safety' THEN 'تجهیزات ایمنی ساختمانی'
        WHEN 'fashion_underwear_beach' THEN 'لباس زیر و لباس ساحلی'
        WHEN 'fashion_sport' THEN 'پوشاک ورزشی'
        WHEN 'signaling_and_security' THEN 'سیگنالینگ و امنیت'
        WHEN 'computers' THEN 'کامپیوتر'
        WHEN 'christmas_supplies' THEN 'لوازم کریسمس'
        WHEN 'fashio_female_clothing' THEN 'پوشاک زنانه'
        WHEN 'home_appliances_2' THEN 'لوازم خانگی'
        WHEN 'books_imported' THEN 'کتاب‌های وارداتی'
        WHEN 'drinks' THEN 'نوشیدنی‌ها'
        WHEN 'cine_photo' THEN 'عکاسی و فیلم‌برداری'
        WHEN 'la_cuisine' THEN 'آشپزی و لوازم آشپزخانه'
        WHEN 'music' THEN 'موسیقی'
        WHEN 'home_comfort_2' THEN 'لوازم راحتی منزل'
        WHEN 'small_appliances_home_oven_and_coffee' THEN 'لوازم کوچک آشپزخانه، فر و قهوه‌ساز'
        WHEN 'cds_dvds_musicals' THEN 'CD، DVD و محصولات موسیقی'
        WHEN 'dvds_blu_ray' THEN 'DVD و Blu-ray'
        WHEN 'flowers' THEN 'گل و گیاه'
        WHEN 'arts_and_craftmanship' THEN 'هنر و صنایع دستی'
        WHEN 'diapers_and_hygiene' THEN 'پوشک و محصولات بهداشتی'
        WHEN 'fashion_childrens_clothes' THEN 'پوشاک کودکان'
        WHEN 'security_and_services' THEN 'امنیت و خدمات'
        ELSE NULL
    END;


-- 4. Drop rows with NULLs

-- 4.1 COUNT of nulls in product_category_name column
SELECT COUNT(*) AS null_count 
FROM stg.products
WHERE product_category_name IS NULL;

-- 4.2 DELETE null values
DELETE FROM stg.products
WHERE product_category_name IS NULL;

-- FINISHED