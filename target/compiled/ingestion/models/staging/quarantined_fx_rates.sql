

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_fx_rates"
WHERE quarantine_reason IS NOT NULL