{{ config(materialized='table') }}

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN applicant_name IS NULL OR trim(applicant_name) = '' THEN 'missing_applicant_name'
            WHEN screened_on IS NOT NULL
                 AND try_cast(screened_on AS DATE) IS NULL
                THEN 'invalid_screened_on'
            WHEN decision IS NULL OR trim(decision) = '' THEN 'missing_decision'
            WHEN decision IS NOT NULL
                 AND lower(trim(decision)) NOT IN ('approve','approved','decline','declined','review','pending')
                THEN 'invalid_decision'
            ELSE NULL
        END AS quarantine_reason
    FROM {{ ref('raw_investment_screening') }}
)
SELECT * FROM scored