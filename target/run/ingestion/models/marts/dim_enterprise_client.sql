
    

    create  table
      "ingestion"."main_marts"."dim_enterprise_client__dbt_tmp"
  
    
    as (
      

WITH ims AS (
    SELECT * FROM "ingestion"."main_intermediate"."int_client_identity_prepped" WHERE source_system = 'ims'
),
cbs AS (
    SELECT * FROM "ingestion"."main_intermediate"."int_client_identity_prepped" WHERE source_system = 'cbs'
),
auto AS (
    SELECT ims_client_id, borrower_id
    FROM "ingestion"."main_intermediate"."int_client_identity_auto_matches"
),


ims_to_cbs AS (
    SELECT ims_client_id, borrower_id
    FROM auto
    GROUP BY ims_client_id, borrower_id
),


paired AS (
    SELECT
        i.ims_client_id,
        m.borrower_id,
        i.is_minor AS ims_is_minor,
        b.is_minor AS cbs_is_minor
    FROM ims i
    LEFT JOIN ims_to_cbs m ON i.ims_client_id = m.ims_client_id
    LEFT JOIN cbs b ON m.borrower_id = b.borrower_id
),


cbs_only AS (
    SELECT
        NULL AS ims_client_id,
        c.borrower_id,
        NULL AS ims_is_minor,
        c.is_minor AS cbs_is_minor
    FROM cbs c
    WHERE c.borrower_id NOT IN (
        SELECT borrower_id FROM ims_to_cbs WHERE borrower_id IS NOT NULL
    )
),

all_rows AS (
    SELECT * FROM paired
    UNION ALL
    SELECT * FROM cbs_only
),

with_enterprise_id AS (
    SELECT
        ims_client_id,
        borrower_id,
        ims_is_minor,
        cbs_is_minor,
        CASE
            WHEN borrower_id IS NOT NULL THEN 'ent_' || md5('cbs:' || borrower_id)
            WHEN ims_client_id IS NOT NULL THEN 'ent_' || md5('ims:' || ims_client_id)
            ELSE NULL
        END AS enterprise_client_id,
        CASE
            WHEN borrower_id IS NOT NULL AND ims_client_id IS NOT NULL THEN 'auto_matched'
            WHEN borrower_id IS NOT NULL THEN 'unmatched_cbs'
            WHEN ims_client_id IS NOT NULL THEN 'unmatched_ims'
            ELSE 'orphan'
        END AS link_status
    FROM all_rows
),

flagged AS (
    SELECT
        enterprise_client_id,
        ims_client_id,
        borrower_id,
        link_status,
        CASE
        
            WHEN ims_is_minor IS TRUE OR cbs_is_minor IS TRUE THEN TRUE
            
            WHEN ims_is_minor IS NULL AND cbs_is_minor IS NULL THEN TRUE
            
            ELSE FALSE
        END AS is_minor_restricted
    FROM with_enterprise_id
)

SELECT
    enterprise_client_id,
    ims_client_id,
    borrower_id,
    link_status,
    is_minor_restricted
FROM flagged
    );
    
  