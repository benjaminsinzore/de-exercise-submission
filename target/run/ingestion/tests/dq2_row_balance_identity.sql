
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select
    source,
    raw_count,
    clean_count,
    quarantined_count,
    balance_delta
from "ingestion"."main"."dq2_row_balance"
where raw_count <> clean_count + quarantined_count
  
  
      
    ) dbt_internal_test