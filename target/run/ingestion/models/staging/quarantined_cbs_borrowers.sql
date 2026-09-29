
    

    create  table
      "ingestion"."main"."quarantined_cbs_borrowers__dbt_tmp"
  
    
    as (
      

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_cbs_borrowers"
WHERE quarantine_reason IS NOT NULL
    );
    
  