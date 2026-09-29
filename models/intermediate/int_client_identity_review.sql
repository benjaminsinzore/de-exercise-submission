{{ config(materialized='table') }}

WITH candidates AS (
    SELECT * FROM {{ ref('int_client_identity_candidates') }}
),
auto AS (
    SELECT ims_client_id, borrower_id FROM {{ ref('int_client_identity_auto_matches') }}
),
ambiguous_ims AS (
    SELECT ims_client_id
    FROM candidates
    WHERE match_score >= 95
    GROUP BY ims_client_id
    HAVING COUNT(*) > 1
),
ambiguous_cbs AS (
    SELECT borrower_id
    FROM candidates
    WHERE match_score >= 95
    GROUP BY borrower_id
    HAVING COUNT(*) > 1
),


existing_review AS (
    SELECT
        c.ims_client_id,
        c.borrower_id,
        c.match_score,
        c.match_reason,
        CASE
            WHEN c.involves_minor AND c.match_score < 100 THEN 'minor_requires_exact_id'
            WHEN c.ims_client_id IN (SELECT ims_client_id FROM ambiguous_ims) THEN 'ambiguous_ims'
            WHEN c.borrower_id IN (SELECT borrower_id FROM ambiguous_cbs) THEN 'ambiguous_borrower'
            WHEN c.match_score BETWEEN 50 AND 94 THEN 'medium_confidence'
            WHEN c.match_score >= 95 THEN 'high_confidence_but_not_auto'
            ELSE 'low_confidence'
        END AS review_reason,
        c.involves_minor
    FROM candidates c
    LEFT JOIN auto a
      ON c.ims_client_id = a.ims_client_id
     AND c.borrower_id = a.borrower_id
    WHERE a.ims_client_id IS NULL
      AND c.match_score >= 50
),


duplicate_ims AS (
    SELECT
        ims_client_id,
        NULL AS borrower_id,
        NULL AS match_score,
        'duplicate_ims_client_id' AS match_reason,
        'duplicate_ims_client_id' AS review_reason,
        (MIN(try_cast(date_of_birth AS DATE)) > current_date - INTERVAL 18 YEAR) AS involves_minor
    FROM {{ ref('raw_ims_clients') }}
    GROUP BY ims_client_id
    HAVING COUNT(*) > 1
)

SELECT
    ims_client_id,
    borrower_id,
    match_score,
    match_reason,
    review_reason,
    involves_minor
FROM existing_review
UNION ALL
SELECT
    ims_client_id,
    borrower_id,
    match_score,
    match_reason,
    review_reason,
    involves_minor
FROM duplicate_ims