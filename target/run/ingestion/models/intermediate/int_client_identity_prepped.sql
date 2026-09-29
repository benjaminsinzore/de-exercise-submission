
    

    create  table
      "ingestion"."main_intermediate"."int_client_identity_prepped__dbt_tmp"
  
    
    as (
      

WITH ims AS (
    SELECT
        'ims' AS source_system,
        ims_client_id,
        NULL AS borrower_id,
        regexp_replace(
            regexp_replace(
                lower(trim(
                    coalesce(first_name, '') || ' ' ||
                    coalesce(middle_name, '') || ' ' ||
                    coalesce(last_name, '')
                )),
                '\s+', ' ', 'g'
            ),
            '[^a-z0-9 ]', '', 'g'
        ) AS full_name_norm,
        regexp_replace(lower(trim(coalesce(first_name, ''))), '[^a-z0-9]', '', 'g') AS first_name_norm,
        regexp_replace(lower(trim(coalesce(last_name,  ''))), '[^a-z0-9]', '', 'g') AS last_name_norm,
        try_cast(date_of_birth AS DATE) AS dob,
        CASE
            WHEN sex IS NULL OR trim(sex) = '' THEN NULL
            WHEN lower(trim(sex)) IN ('female','f','woman','2') THEN 'female'
            WHEN lower(trim(sex)) IN ('male','m','man','1') THEN 'male'
            ELSE lower(trim(sex))
        END AS gender_norm,
        right(regexp_replace(coalesce(phone_1, phone_2, ''), '[^0-9]', '', 'g'), 9) AS phone_norm,
        lower(trim(country)) AS country_norm,
        lower(trim(id_document_type)) AS id_type_norm,
        regexp_replace(lower(trim(id_document_number)), '[^a-z0-9]', '', 'g') AS id_number_norm,
        date_diff(
        'year',
        COALESCE(
            TRY_CAST(date_of_birth AS DATE),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d/%m/%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d-%m-%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%Y/%m/%d'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d.%m.%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%m/%d/%Y')
        ),
        current_date
    ) < 18
 AS is_minor
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY ims_client_id
                ORDER BY
                    try_cast(updated_at AS TIMESTAMP) DESC NULLS LAST,
                    try_cast(registration_date AS DATE) DESC NULLS LAST
            ) AS rn
        FROM "ingestion"."main_raw"."raw_ims_clients"
    )
    WHERE rn = 1
),
cbs AS (
    SELECT
        'cbs' AS source_system,
        NULL AS ims_client_id,
        borrower_id AS borrower_id,
        regexp_replace(
            regexp_replace(
                lower(trim(full_name)),
                '\s+', ' ', 'g'
            ),
            '[^a-z0-9 ]', '', 'g'
        ) AS full_name_norm,
        regexp_replace(
            lower(trim(split_part(full_name, ' ', 1))),
            '[^a-z0-9]', '', 'g'
        ) AS first_name_norm,
        regexp_replace(
            lower(trim(regexp_extract(full_name, '([^ ]+)\s*$', 1))),
            '[^a-z0-9]', '', 'g'
        ) AS last_name_norm,
        try_cast(date_of_birth AS DATE) AS dob,
        CASE
            WHEN gender IS NULL OR trim(gender) = '' THEN NULL
            WHEN lower(trim(gender)) IN ('female','f','woman','2') THEN 'female'
            WHEN lower(trim(gender)) IN ('male','m','man','1') THEN 'male'
            ELSE lower(trim(gender))
        END AS gender_norm,
        right(regexp_replace(coalesce(mobile_no, ''), '[^0-9]', '', 'g'), 9) AS phone_norm,
        lower(trim(country)) AS country_norm,
        lower(trim(id_type)) AS id_type_norm,
        regexp_replace(lower(trim(id_number)), '[^a-z0-9]', '', 'g') AS id_number_norm,
        date_diff(
        'year',
        COALESCE(
            TRY_CAST(date_of_birth AS DATE),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d/%m/%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d-%m-%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%Y/%m/%d'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%d.%m.%Y'),
            TRY_STRPTIME(CAST(date_of_birth AS VARCHAR), '%m/%d/%Y')
        ),
        current_date
    ) < 18
 AS is_minor
    FROM "ingestion"."main_raw"."raw_cbs_borrowers"
)
SELECT * FROM ims
UNION ALL
SELECT * FROM cbs
    );
    
  