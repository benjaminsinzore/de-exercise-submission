
    

    create  table
      "ingestion"."main"."quarantined_ims_clients__dbt_tmp"
  
    
    as (
      

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_ims_clients"
WHERE quarantine_reason IS NOT NULL
    );
    
  