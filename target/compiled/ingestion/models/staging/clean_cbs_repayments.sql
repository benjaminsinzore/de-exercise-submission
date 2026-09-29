

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_repayments"
WHERE quarantine_reason IS NULL