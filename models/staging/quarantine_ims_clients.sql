{{ config(materialized='table') }}

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN ims_client_id IS NULL OR ims_client_id = '' THEN 'missing_ims_client_id'
            WHEN coalesce(trim(first_name), '') = ''
                 AND coalesce(trim(last_name), '') = ''
                THEN 'missing_full_name'
            WHEN date_of_birth IS NOT NULL
                 AND try_cast(date_of_birth AS DATE) IS NULL
                THEN 'unparseable_date_of_birth'
            WHEN try_cast(date_of_birth AS DATE) > current_date
                THEN 'future_date_of_birth'
            WHEN try_cast(date_of_birth AS DATE) < date '1900-01-01'
                THEN 'implausible_date_of_birth'
            WHEN country IS NULL OR trim(country) = '' THEN 'missing_country'
            WHEN sex IS NOT NULL
                 AND lower(trim(sex)) NOT IN ('male','female','m','f')
                THEN 'invalid_sex'
            ELSE NULL
        END AS quarantine_reason
    FROM {{ ref('raw_ims_clients') }}
)
SELECT * FROM scored