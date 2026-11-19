CREATE VIEW dw.vw_seller_distribution_by_city
AS
SELECT
    seller_city,
    COUNT(seller_id) AS seller_count
FROM dw.dim_sellers
GROUP BY seller_city;

DROP VIEW dw.vw_seller_distribution_by_city;