{{ config(materialized='table') }}

SELECT
    *,
    current_timestamp AS quarantined_at
FROM {{ ref('quarantine_investment_screening') }}
WHERE quarantine_reason IS NOT NULL