CREATE VIEW dw.vw_seller_distribution_by_state
AS
SELECT
    seller_state,
    COUNT(seller_id) as seller_count
FROM dw.dim_sellers
GROUP BY seller_state;

DROP VIEW dw.vw_seller_distribution_by_state;