CREATE VIEW dw.vw_total_revenue_by_category
AS
SELECT
    p.product_category_name_persian AS product_category,

    DATEFROMPARTS(
        YEAR(f.order_purchase_timestamp),
        MONTH(f.order_purchase_timestamp),
        1
    ) AS purchase_month,

    CAST(
        SUM(f.price + f.freight_value)
        AS DECIMAL(18,2)
    ) AS total_revenue,

    CAST(
        SUM(f.freight_value) * 100.0
        / NULLIF(SUM(f.price + f.freight_value), 0)
        AS DECIMAL(10,2)
    ) AS freight_percentage

FROM dw.fact_order_items AS f

INNER JOIN dw.dim_products AS p
    ON f.product_key = p.product_key

WHERE
    p.product_category_name_persian IS NOT NULL

GROUP BY
    p.product_category_name_persian,
    YEAR(f.order_purchase_timestamp),
    MONTH(f.order_purchase_timestamp);
GO

drop view dw.vw_total_revenue_by_category