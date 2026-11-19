CREATE VIEW dw.vw_customer_distribution_by_state
AS
SELECT
    customer_state,
    COUNT(customer_id) as customer_count
FROM dw.dim_customers
GROUP BY customer_state;

DROP VIEW dw.vw_customer_distribution_by_state;