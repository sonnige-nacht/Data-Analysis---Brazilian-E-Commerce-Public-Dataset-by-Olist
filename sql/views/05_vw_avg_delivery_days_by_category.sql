CREATE VIEW dw.vw_avg_delivery_days_by_category
AS
SELECT
    p.product_category_name_persian AS product_category,
    YEAR(f.order_purchase_timestamp) AS order_year,

    CAST(
        AVG(
            DATEDIFF(
                DAY,
                f.order_purchase_timestamp,
                f.order_delivered_customer_date
            ) * 1.0
        ) AS DECIMAL(10,2)
    ) AS avg_delivery_days

FROM dw.fact_order_items AS f

INNER JOIN dw.dim_products AS p
    ON f.product_key = p.product_key

WHERE
    f.order_status = 'delivered'
    AND f.order_delivered_customer_date IS NOT NULL
    AND p.product_category_name_persian IS NOT NULL

GROUP BY
    p.product_category_name_persian,
    YEAR(f.order_purchase_timestamp);
GO

drop view dw.vw_avg_delivery_days_by_category;