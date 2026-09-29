
    

    create  table
      "ingestion"."main"."clean_cbs_repayments__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_repayments"
WHERE quarantine_reason IS NULL
    );
    
  