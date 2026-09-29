{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_cbs_repayments') }}
WHERE quarantine_reason IS NULL