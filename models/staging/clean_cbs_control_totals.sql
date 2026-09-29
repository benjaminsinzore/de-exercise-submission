{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_cbs_control_totals') }}
WHERE quarantine_reason IS NULL