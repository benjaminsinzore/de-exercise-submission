

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_borrowers"
WHERE quarantine_reason IS NULL