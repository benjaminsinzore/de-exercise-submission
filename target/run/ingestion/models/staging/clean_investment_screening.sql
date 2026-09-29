
    

    create  table
      "ingestion"."main"."clean_investment_screening__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_investment_screening"
WHERE quarantine_reason IS NULL
    );
    
  