
    

    create  table
      "ingestion"."main"."quarantine_investment_screening__dbt_tmp"
  
    
    as (
      

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN applicant_name IS NULL OR trim(applicant_name) = '' THEN 'missing_applicant_name'
            WHEN screened_on IS NOT NULL
                 AND try_cast(screened_on AS DATE) IS NULL
                THEN 'invalid_screened_on'
            WHEN decision IS NULL OR trim(decision) = '' THEN 'missing_decision'
            WHEN decision IS NOT NULL
                 AND lower(trim(decision)) NOT IN ('approve','approved','decline','declined','review','pending')
                THEN 'invalid_decision'
            ELSE NULL
        END AS quarantine_reason
    FROM "ingestion"."main_raw"."raw_investment_screening"
)
SELECT * FROM scored
    );
    
  