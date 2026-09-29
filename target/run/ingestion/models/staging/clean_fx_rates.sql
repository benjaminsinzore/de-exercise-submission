
    

    create  table
      "ingestion"."main"."clean_fx_rates__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_fx_rates"
WHERE quarantine_reason IS NULL
    );
    
  