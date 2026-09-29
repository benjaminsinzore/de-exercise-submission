{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_fx_rates') }}
WHERE quarantine_reason IS NULL