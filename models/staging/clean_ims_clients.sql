{{ config(materialized='table') }}

SELECT * EXCLUDE (quarantine_reason)
FROM {{ ref('quarantine_ims_clients') }}
WHERE quarantine_reason IS NULL