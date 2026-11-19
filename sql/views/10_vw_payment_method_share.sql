CREATE VIEW dw.vw_payment_method_share
AS

SELECT
    payment_type,
    YEAR(order_purchase_timestamp) AS payment_year,

    CAST(
        COUNT(DISTINCT order_id) * 100.0
        / SUM(COUNT(DISTINCT order_id)) OVER (
            PARTITION BY YEAR(order_purchase_timestamp)
        )
        AS DECIMAL(5,2)
    ) AS payment_share_percentage

FROM dw.fact_order_payments

GROUP BY
    payment_type,
    YEAR(order_purchase_timestamp);
GO

drop view dw.vw_payment_method_share;