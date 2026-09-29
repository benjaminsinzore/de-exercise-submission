
    

    create  table
      "ingestion"."main_raw"."raw_fx_rates__dbt_tmp"
  
    
    as (
      



WITH src AS (
    SELECT
        
        *
        
    FROM read_csv_auto(
        'source/fx_rates.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY currency, rate_date, rate_type, source
            ORDER BY published_at DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT * EXCLUDE (rn)
FROM dedup
WHERE rn = 1
    );
    
  