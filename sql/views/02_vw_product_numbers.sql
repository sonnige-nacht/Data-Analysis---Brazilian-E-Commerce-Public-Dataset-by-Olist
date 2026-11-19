CREATE VIEW dw.vw_product_numbers
AS
SELECT
    product_category_name_persian as product_category,
    COUNT(product_id) as product_count
FROM dw.dim_products
GROUP BY product_category_name_persian;

DROP VIEW dw.vw_product_numbers;