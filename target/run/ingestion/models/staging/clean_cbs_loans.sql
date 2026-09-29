
    

    create  table
      "ingestion"."main"."clean_cbs_loans__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_loans"
WHERE quarantine_reason IS NULL
    );
    
  