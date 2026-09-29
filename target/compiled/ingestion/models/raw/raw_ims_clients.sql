




WITH src AS (
    SELECT
        
        *,
        
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
    FROM read_csv_auto(
        'source/ims_clients.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ims_client_id
            ORDER BY
                updated_at DESC NULLS LAST,
                registration_date DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT
    * EXCLUDE (rn),
    CASE
        WHEN is_minor IS NOT FALSE THEN 'restricted'
        ELSE 'personal'
    END AS data_class
FROM dedup
WHERE rn = 1
