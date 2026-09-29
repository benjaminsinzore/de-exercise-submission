{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_cbs_loans') }}
WHERE quarantine_reason IS NULL