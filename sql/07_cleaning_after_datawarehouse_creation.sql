-- data cleaning after creation Datawarehouse

-- Translation problem in dw.dim_products
SELECT
    product_category_name,
    product_category_name_english,
    COUNT(product_id) AS product_count
FROM dw.dim_products
WHERE product_category_name IS NOT NULL
  AND product_category_name_english IS NULL
GROUP BY
    product_category_name,
    product_category_name_english;


UPDATE dw.dim_products
SET
    product_category_name_english = 'gaming_pc',
    product_category_name_persian = N'کامپیوتر گیمینگ'
WHERE product_category_name = 'pc_gamer';

UPDATE dw.dim_products
SET
    product_category_name_english = 'kitchen_appliances_food_processors',
    product_category_name_persian = N'لوازم آشپزخانه و غذاسازها'
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos';



-- not defined values in payment type
SELECT COUNT(*) AS not_defined_count
FROM dw.fact_order_payments
WHERE payment_type = 'not_defined';

DELETE FROM dw.fact_order_payments
WHERE payment_type = 'not_defined';