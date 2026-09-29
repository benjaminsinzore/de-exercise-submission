

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_investment_screening"
WHERE quarantine_reason IS NOT NULL