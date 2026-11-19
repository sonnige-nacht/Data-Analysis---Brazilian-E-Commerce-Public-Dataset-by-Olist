CREATE VIEW dw.vw_customer_distribution_by_city
AS
SELECT
    customer_city,
    COUNT(customer_id) as customer_count
FROM dw.dim_customers
GROUP BY customer_city;

DROP VIEW dw.vw_customer_distribution_by_city;