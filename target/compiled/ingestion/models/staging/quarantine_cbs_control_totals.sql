

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN country IS NULL OR trim(country) = '' THEN 'missing_country'
            WHEN month IS NULL OR trim(cast(month as varchar)) = '' THEN 'missing_month'
            WHEN NOT regexp_matches(cast(month as varchar), '^[0-9]{4}-[0-9]{2}$')
                THEN 'invalid_month_format'
            WHEN TRY_CAST(loans_disbursed_count AS INTEGER) IS NULL
                THEN 'unparseable_loans_count'
            WHEN TRY_CAST(loans_disbursed_count AS INTEGER) < 0
                THEN 'negative_loans_count'
            WHEN TRY_CAST(repayments_count AS INTEGER) IS NULL
                THEN 'unparseable_repayments_count'
            WHEN TRY_CAST(repayments_count AS INTEGER) < 0
                THEN 'negative_repayments_count'
            WHEN TRY_CAST(loans_disbursed_amount AS DOUBLE) IS NULL
                THEN 'unparseable_loans_amount'
            WHEN TRY_CAST(repayments_amount AS DOUBLE) IS NULL
                THEN 'unparseable_repayments_amount'
            ELSE NULL
        END AS quarantine_reason
    FROM "ingestion"."main_raw"."raw_cbs_control_totals"
)
SELECT * FROM scored