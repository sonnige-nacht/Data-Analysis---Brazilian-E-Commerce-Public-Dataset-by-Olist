CREATE VIEW dw.vw_avg_transit_days_by_seller_state
AS
SELECT
    s.seller_state,
    YEAR(o.order_purchase_timestamp) AS order_year,

    CAST(
        AVG(
            DATEDIFF(
                DAY,
                o.order_delivered_carrier_date,
                o.order_delivered_customer_date
            ) * 1.0
        ) AS DECIMAL(10,2)
    ) AS avg_transit_days

FROM dw.fact_order_items AS o

INNER JOIN dw.dim_sellers AS s
    ON o.seller_key = s.seller_key

WHERE
    o.order_delivered_carrier_date IS NOT NULL
    AND o.order_delivered_customer_date IS NOT NULL

GROUP BY
    s.seller_state,
    YEAR(o.order_purchase_timestamp);
GO

drop view dw.vw_avg_transit_days_by_seller_state;