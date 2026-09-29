

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN currency IS NULL OR trim(currency) = '' THEN 'missing_currency'
            WHEN rate_date IS NULL THEN 'missing_rate_date'
            WHEN rate_type IS NULL OR trim(rate_type) = '' THEN 'missing_rate_type'
            WHEN TRY_CAST(units_per_usd AS DOUBLE) IS NULL THEN 'unparseable_units_per_usd'
            WHEN TRY_CAST(units_per_usd AS DOUBLE) <= 0 THEN 'non_positive_units_per_usd'
            ELSE NULL
        END AS quarantine_reason
    FROM "ingestion"."main_raw"."raw_fx_rates"
)
SELECT * FROM scored