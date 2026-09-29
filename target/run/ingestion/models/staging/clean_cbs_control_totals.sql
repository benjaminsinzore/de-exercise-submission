
    

    create  table
      "ingestion"."main"."clean_cbs_control_totals__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_cbs_control_totals"
WHERE quarantine_reason IS NULL
    );
    
  