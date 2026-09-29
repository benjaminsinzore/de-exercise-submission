
    

    create  table
      "ingestion"."main"."quarantined_fx_rates__dbt_tmp"
  
    
    as (
      

SELECT
    *,
    current_timestamp AS quarantined_at
FROM "ingestion"."main"."quarantine_fx_rates"
WHERE quarantine_reason IS NOT NULL
    );
    
  