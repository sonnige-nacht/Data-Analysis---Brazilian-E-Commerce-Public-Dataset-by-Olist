CREATE VIEW dw.vw_avg_product_logistics_by_category
AS
SELECT
    product_category_name_persian as product_category,

    -- Average Product Volume (cm³)
    CAST(
        AVG(
            product_length_cm
            * product_height_cm
            * product_width_cm
        ) AS DECIMAL(18,2)
    ) AS avg_product_volume_cm3,

    -- Average Product Weight (g)
    CAST(
        AVG(product_weight_g) AS DECIMAL(18,2)
    ) AS avg_product_weight_g,

    -- Average Product Density (g/cm^3)
    CAST(
        AVG(
            CAST(product_weight_g AS DECIMAL(18,4))
            /
            NULLIF(
                product_length_cm
                * product_height_cm
                * product_width_cm,
                0
            )
        ) AS DECIMAL(18,4)
    ) AS avg_product_density_g_cm3

FROM dw.dim_products

WHERE
    product_length_cm IS NOT NULL
    AND product_height_cm IS NOT NULL
    AND product_width_cm IS NOT NULL
    AND product_weight_g IS NOT NULL

GROUP BY
    product_category_name_persian;
GO

drop view dw.vw_avg_product_logistics_by_category;