{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_investment_screening') }}
WHERE quarantine_reason IS NULL