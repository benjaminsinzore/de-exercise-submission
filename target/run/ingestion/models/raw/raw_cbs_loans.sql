
    

    create  table
      "ingestion"."main_raw"."raw_cbs_loans__dbt_tmp"
  
    
    as (
      



WITH src AS (
    SELECT
        
        *
        
    FROM read_csv_auto(
        'source/cbs_loans.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY disbursed_at DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT * EXCLUDE (rn)
FROM dedup
WHERE rn = 1
    );
    
  