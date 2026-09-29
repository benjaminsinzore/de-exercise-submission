
    

    create  table
      "ingestion"."main"."clean_ims_clients__dbt_tmp"
  
    
    as (
      

SELECT * EXCLUDE (quarantine_reason)
FROM "ingestion"."main"."quarantine_ims_clients"
WHERE quarantine_reason IS NULL
    );
    
  