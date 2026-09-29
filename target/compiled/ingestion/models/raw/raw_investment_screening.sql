



WITH src AS (
    SELECT
        
        *,
        
        NULL::BOOLEAN AS is_minor,
        'unknown' AS minor_status,
        'personal' AS data_class
    FROM read_csv_auto(
        'source/investment_screening.csv',
        header = true
    )
)
SELECT DISTINCT *
FROM src