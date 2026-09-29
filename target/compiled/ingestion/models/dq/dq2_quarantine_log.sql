




SELECT
    'cbs_loans' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_cbs_loans"
GROUP BY 1, 2
UNION ALL

SELECT
    'cbs_borrowers' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_cbs_borrowers"
GROUP BY 1, 2
UNION ALL

SELECT
    'ims_clients' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_ims_clients"
GROUP BY 1, 2
UNION ALL

SELECT
    'cbs_repayments' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_cbs_repayments"
GROUP BY 1, 2
UNION ALL

SELECT
    'fx_rates' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_fx_rates"
GROUP BY 1, 2
UNION ALL

SELECT
    'cbs_control_totals' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_cbs_control_totals"
GROUP BY 1, 2
UNION ALL

SELECT
    'investment_screening' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM "ingestion"."main"."quarantined_investment_screening"
GROUP BY 1, 2

