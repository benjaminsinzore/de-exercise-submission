{{ config(materialized='table') }}

SELECT
    *,
    current_timestamp AS quarantined_at
FROM {{ ref('quarantine_cbs_repayments') }}
WHERE quarantine_reason IS NOT NULL