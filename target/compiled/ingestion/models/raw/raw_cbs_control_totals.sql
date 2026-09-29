



WITH src AS (
    SELECT
        
        *
        
    FROM read_csv_auto(
        'source/cbs_control_totals.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY country, month, currency
            ORDER BY
                loans_disbursed_amount DESC NULLS LAST,
                repayments_amount DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT * EXCLUDE (rn)
FROM dedup
WHERE rn = 1