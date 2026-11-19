CREATE VIEW dw.vw_order_count_by_customer_state
AS
SELECT
    c.customer_state,
    YEAR(o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT o.order_id) AS order_count

FROM dw.fact_order_items AS o

INNER JOIN dw.dim_customers AS c
    ON o.customer_key = c.customer_key

GROUP BY
    c.customer_state,
    YEAR(o.order_purchase_timestamp);
GO

drop view dw.vw_order_count_by_customer_state;