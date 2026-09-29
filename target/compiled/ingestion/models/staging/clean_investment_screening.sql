

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_investment_screening"
WHERE quarantine_reason IS NULL