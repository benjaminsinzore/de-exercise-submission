{{ config(materialized='table') }}

SELECT
    *,
    current_timestamp AS quarantined_at
FROM {{ ref('quarantine_fx_rates') }}
WHERE quarantine_reason IS NOT NULL