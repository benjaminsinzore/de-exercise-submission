

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_loans"
WHERE quarantine_reason IS NULL