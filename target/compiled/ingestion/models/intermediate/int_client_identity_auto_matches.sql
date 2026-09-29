

WITH hc AS (
    SELECT *
    FROM "ingestion"."main_intermediate"."int_client_identity_candidates"
    WHERE match_score >= 95
      AND NOT (involves_minor AND match_score < 100)
),
ims_counts AS (
    SELECT ims_client_id, COUNT(*) AS ims_match_count
    FROM hc
    GROUP BY ims_client_id
),
cbs_counts AS (
    SELECT borrower_id, COUNT(*) AS cbs_match_count
    FROM hc
    GROUP BY borrower_id
)
SELECT hc.*
FROM hc
JOIN ims_counts i ON hc.ims_client_id = i.ims_client_id
JOIN cbs_counts c ON hc.borrower_id = c.borrower_id
WHERE i.ims_match_count = 1
  AND c.cbs_match_count = 1