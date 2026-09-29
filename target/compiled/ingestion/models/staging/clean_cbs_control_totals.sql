

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_control_totals"
WHERE quarantine_reason IS NULL