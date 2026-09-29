

WITH
ims_total AS (
    SELECT count(*) AS total FROM "ingestion"."main_raw"."raw_ims_clients"
),
cbs_total AS (
    SELECT count(*) AS total FROM "ingestion"."main_raw"."raw_cbs_borrowers"
),
auto_matched AS (
    SELECT
        count(*) AS pairs,
        count(DISTINCT ims_client_id) AS ims_matched,
        count(DISTINCT borrower_id) AS cbs_matched
    FROM "ingestion"."main_intermediate"."int_client_identity_auto_matches"
),
review AS (
    SELECT
        count(*) AS review_rows,
        count(DISTINCT ims_client_id) AS review_ims,
        count(DISTINCT borrower_id) AS review_cbs
    FROM "ingestion"."main_intermediate"."int_client_identity_review"
),
unmatched_ims AS (
    SELECT count(*) AS unmatched
    FROM "ingestion"."main_raw"."raw_ims_clients" r
    WHERE r.ims_client_id NOT IN (
        SELECT ims_client_id
        FROM "ingestion"."main_intermediate"."int_client_identity_auto_matches"
        WHERE ims_client_id IS NOT NULL
    )
),
unmatched_cbs AS (
    SELECT count(*) AS unmatched
    FROM "ingestion"."main_raw"."raw_cbs_borrowers" r
    WHERE r.borrower_id NOT IN (
        SELECT borrower_id
        FROM "ingestion"."main_intermediate"."int_client_identity_auto_matches"
        WHERE borrower_id IS NOT NULL
    )
)
SELECT
    (SELECT total FROM ims_total) AS ims_total,
    (SELECT total FROM cbs_total) AS cbs_total,
    (SELECT pairs FROM auto_matched) AS auto_matched_pairs,
    (SELECT ims_matched FROM auto_matched) AS ims_matched,
    (SELECT cbs_matched FROM auto_matched) AS cbs_matched,
    (SELECT unmatched FROM unmatched_ims) AS ims_unmatched,
    (SELECT unmatched FROM unmatched_cbs) AS cbs_unmatched,
    (SELECT review_rows FROM review) AS review_queue_rows,
    (SELECT review_ims FROM review) AS review_queue_ims,
    (SELECT review_cbs FROM review) AS review_queue_cbs