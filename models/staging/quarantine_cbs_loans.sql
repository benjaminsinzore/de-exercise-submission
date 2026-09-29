{{ config(materialized='table') }}

WITH raw AS (
    SELECT * FROM {{ ref('raw_cbs_loans') }}
),
scored AS (
    SELECT
        *,
        CASE
            WHEN loan_id IS NULL THEN 'missing_loan_id'
            WHEN borrower_id IS NULL THEN 'missing_borrower_id'
            WHEN currency IS NULL OR upper(currency) NOT IN ('KES','KSH','ETB','RWF','SSP','XAF')
                THEN 'invalid_currency'
            WHEN principal IS NULL THEN 'missing_principal'
            WHEN TRY_CAST(principal AS DOUBLE) IS NULL
                 AND TRY_CAST(regexp_replace(CAST(principal AS VARCHAR), '[^0-9.\-]', '', 'g') AS DOUBLE) IS NULL
                THEN 'unparseable_principal'
            WHEN TRY_CAST(principal AS DOUBLE) < 0
                 OR TRY_CAST(regexp_replace(CAST(principal AS VARCHAR), '[^0-9.\-]', '', 'g') AS DOUBLE) < 0
                THEN 'negative_principal'
            WHEN TRY_CAST(disbursed_at AS TIMESTAMP) IS NULL THEN 'invalid_disbursed_at'
            WHEN TRY_CAST(term_months AS INTEGER) IS NOT NULL AND TRY_CAST(term_months AS INTEGER) <= 0
                THEN 'invalid_term'
            WHEN TRY_CAST(interest_rate_pct AS DOUBLE) IS NOT NULL
                 AND (TRY_CAST(interest_rate_pct AS DOUBLE) < 0 OR TRY_CAST(interest_rate_pct AS DOUBLE) > 100)
                THEN 'invalid_interest_rate'
            ELSE NULL
        END AS quarantine_reason
    FROM raw
)
SELECT * FROM scored