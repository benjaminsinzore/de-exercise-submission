

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_cbs_repayments"
WHERE quarantine_reason IS NOT NULL