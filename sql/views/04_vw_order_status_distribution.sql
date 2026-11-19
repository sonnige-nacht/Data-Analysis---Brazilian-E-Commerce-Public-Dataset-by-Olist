CREATE VIEW dw.vw_order_status_distribution
AS
SELECT
    order_status,
    COUNT(order_id) AS order_count,

    CAST(
        COUNT(order_id) * 100.0
        / SUM(COUNT(order_id)) OVER ()
        AS DECIMAL(5,2)
    ) AS order_percentage

FROM [olist_datawarehouse].[dw].[dim_orders]

GROUP BY
    order_status;
GO

drop view dw.vw_order_status_distribution