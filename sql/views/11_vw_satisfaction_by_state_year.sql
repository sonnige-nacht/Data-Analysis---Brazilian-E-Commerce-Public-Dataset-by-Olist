CREATE VIEW dw.vw_satisfaction_by_state_year
AS

WITH reviews AS
(
    SELECT DISTINCT
        r.order_id,
        YEAR(r.review_creation_date) AS review_year,
        r.review_score,
        c.customer_state

    FROM dw.fact_order_reviews AS r

    INNER JOIN dw.fact_order_items AS foi
        ON r.order_id = foi.order_id

    INNER JOIN dw.dim_customers AS c
        ON foi.customer_key = c.customer_key

    WHERE YEAR(r.review_creation_date) IN (2016, 2017, 2018)
)

SELECT
    customer_state,
    review_year,

    CAST(
        COUNT(
            CASE
                WHEN review_score >= 3
                THEN 1
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS satisfaction_percentage

FROM reviews

GROUP BY
    customer_state,
    review_year;
GO

drop view dw.vw_satisfaction_by_state_year;