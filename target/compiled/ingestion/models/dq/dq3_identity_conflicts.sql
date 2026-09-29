

WITH linked AS (
    SELECT
        d.enterprise_client_id,
        i.ims_client_id,
        b.borrower_id,
        i.dob AS ims_dob,
        b.dob AS cbs_dob,
        i.country_norm AS ims_country,
        b.country_norm AS cbs_country,
        i.gender_norm AS ims_gender,
        b.gender_norm AS cbs_gender
    FROM "ingestion"."main_intermediate"."int_client_identity_auto_matches" m
    JOIN "ingestion"."main_intermediate"."int_client_identity_prepped" i
      ON m.ims_client_id = i.ims_client_id AND i.source_system = 'ims'
    JOIN "ingestion"."main_intermediate"."int_client_identity_prepped" b
      ON m.borrower_id = b.borrower_id AND b.source_system = 'cbs'
    LEFT JOIN "ingestion"."main_marts"."dim_enterprise_client" d
      ON m.borrower_id = d.borrower_id
),
diffs AS (
    
    SELECT
        enterprise_client_id,
        ims_client_id,
        borrower_id,
        'gender_mismatch' AS conflict,
        'high' AS severity,
        ims_gender AS ims_value,
        cbs_gender AS cbs_value
    FROM linked
    WHERE ims_gender IS NOT NULL
      AND cbs_gender IS NOT NULL
      AND ims_gender <> cbs_gender

    UNION ALL

    
    
    SELECT
        enterprise_client_id,
        ims_client_id,
        borrower_id,
        'dob_mismatch' AS conflict,
        'medium' AS severity,
        CAST(ims_dob AS VARCHAR) AS ims_value,
        CAST(cbs_dob AS VARCHAR) AS cbs_value
    FROM linked
    WHERE ims_dob IS NOT NULL
      AND cbs_dob IS NOT NULL
      AND ims_dob <> cbs_dob
      AND ims_dob <> DATE '1900-01-01'
      AND cbs_dob <> DATE '1900-01-01'

    UNION ALL


    SELECT
        enterprise_client_id,
        ims_client_id,
        borrower_id,
        'country_differs' AS conflict,
        'low' AS severity,
        ims_country AS ims_value,
        cbs_country AS cbs_value
    FROM linked
    WHERE ims_country IS NOT NULL
      AND cbs_country IS NOT NULL
      AND ims_country <> cbs_country
)
SELECT * FROM diffs