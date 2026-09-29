

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_fx_rates"
WHERE quarantine_reason IS NULL