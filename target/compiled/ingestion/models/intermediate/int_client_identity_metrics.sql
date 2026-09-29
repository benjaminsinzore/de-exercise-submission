

WITH ims AS (
    SELECT COUNT(*) AS total_ims FROM "ingestion"."main_raw"."raw_ims_clients"
),
cbs AS (
    SELECT COUNT(*) AS total_cbs FROM "ingestion"."main_raw"."raw_cbs_borrowers"
),
crosswalk AS (
    SELECT
        COUNT(DISTINCT ims_client_id) FILTER (WHERE ims_client_id IS NOT NULL) AS ims_records,
        COUNT(DISTINCT borrower_id) FILTER (WHERE borrower_id IS NOT NULL) AS cbs_records,
        COUNT(DISTINCT ims_client_id) FILTER (WHERE ims_client_id IS NOT NULL AND borrower_id IS NOT NULL) AS ims_matched,
        COUNT(DISTINCT borrower_id) FILTER (WHERE ims_client_id IS NOT NULL AND borrower_id IS NOT NULL) AS cbs_matched,
        COUNT(DISTINCT enterprise_client_id) AS enterprise_clients,
        COUNT(*) FILTER (WHERE link_status = 'unmatched_ims') AS ims_unmatched,
        COUNT(*) FILTER (WHERE link_status = 'unmatched_cbs') AS cbs_unmatched
    FROM "ingestion"."main_marts"."dim_enterprise_client"
),
review AS (
    SELECT COUNT(*) AS review_cases FROM "ingestion"."main_intermediate"."int_client_identity_review"
)
SELECT * FROM ims, cbs, crosswalk, review