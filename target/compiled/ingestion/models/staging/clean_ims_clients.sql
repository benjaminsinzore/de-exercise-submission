

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_ims_clients"
WHERE quarantine_reason IS NULL