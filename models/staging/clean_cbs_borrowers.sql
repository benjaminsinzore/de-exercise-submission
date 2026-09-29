{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_cbs_borrowers') }}
WHERE quarantine_reason IS NULL