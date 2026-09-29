
    

    create  table
      "ingestion"."main_intermediate"."int_client_identity_candidates__dbt_tmp"
  
    
    as (
      

WITH ims AS (
    SELECT * FROM "ingestion"."main_intermediate"."int_client_identity_prepped" WHERE source_system = 'ims'
),
cbs AS (
    SELECT * FROM "ingestion"."main_intermediate"."int_client_identity_prepped" WHERE source_system = 'cbs'
),
candidates AS (
    SELECT
        ims.ims_client_id,
        cbs.borrower_id,
        CASE
            WHEN ims.id_number_norm IS NOT NULL AND ims.id_number_norm != ''
                 AND ims.id_number_norm = cbs.id_number_norm
                 AND (ims.id_type_norm = cbs.id_type_norm OR ims.id_type_norm IS NULL OR cbs.id_type_norm IS NULL)
                THEN 100
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.dob = cbs.dob AND ims.last_name_norm = cbs.last_name_norm
                THEN 98
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.full_name_norm = cbs.full_name_norm AND ims.dob = cbs.dob
                THEN 95
            WHEN ims.full_name_norm = cbs.full_name_norm
                 AND ims.dob = cbs.dob AND ims.country_norm = cbs.country_norm
                THEN 85
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.last_name_norm = cbs.last_name_norm
                THEN 70
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                THEN 60
            WHEN ims.full_name_norm = cbs.full_name_norm
                 AND ims.country_norm = cbs.country_norm
                THEN 50
            ELSE 0
        END AS match_score,
        CASE
            WHEN ims.id_number_norm = cbs.id_number_norm AND ims.id_number_norm IS NOT NULL THEN 'exact_id'
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.dob = cbs.dob AND ims.last_name_norm = cbs.last_name_norm THEN 'phone_dob_last'
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.full_name_norm = cbs.full_name_norm AND ims.dob = cbs.dob THEN 'phone_fullname_dob'
            WHEN ims.full_name_norm = cbs.full_name_norm
                 AND ims.dob = cbs.dob AND ims.country_norm = cbs.country_norm THEN 'fullname_dob_country'
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != ''
                 AND ims.last_name_norm = cbs.last_name_norm THEN 'phone_last'
            WHEN ims.phone_norm = cbs.phone_norm AND ims.phone_norm != '' THEN 'phone_only'
            WHEN ims.full_name_norm = cbs.full_name_norm
                 AND ims.country_norm = cbs.country_norm THEN 'name_country'
            ELSE 'no_match'
        END AS match_reason,
        ims.is_minor AS ims_is_minor,
        cbs.is_minor AS cbs_is_minor,
        (ims.is_minor OR cbs.is_minor) AS involves_minor
    FROM ims
    JOIN cbs
      ON (ims.id_number_norm IS NOT NULL AND ims.id_number_norm != '' AND ims.id_number_norm = cbs.id_number_norm)
      OR (ims.phone_norm != '' AND ims.phone_norm = cbs.phone_norm)
      OR (ims.full_name_norm = cbs.full_name_norm AND ims.dob = cbs.dob)
      OR (ims.full_name_norm = cbs.full_name_norm AND ims.country_norm = cbs.country_norm)
)
SELECT * FROM candidates WHERE match_score > 0
    );
    
  