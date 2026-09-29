

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN borrower_id IS NULL OR borrower_id = '' THEN 'missing_borrower_id'
            WHEN full_name IS NULL OR trim(full_name) = '' THEN 'missing_full_name'
            WHEN date_of_birth IS NOT NULL
                 AND try_cast(date_of_birth AS DATE) IS NULL
                THEN 'unparseable_date_of_birth'
            WHEN try_cast(date_of_birth AS DATE) > current_date
                THEN 'future_date_of_birth'
            WHEN try_cast(date_of_birth AS DATE) < date '1900-01-01'
                THEN 'implausible_date_of_birth'
            WHEN gender IS NOT NULL
                 AND lower(trim(gender)) NOT IN ('male','female','m','f')
                THEN 'invalid_gender'
            ELSE NULL
        END AS quarantine_reason
    FROM "ingestion"."main_raw"."raw_cbs_borrowers"
)
SELECT * FROM scored