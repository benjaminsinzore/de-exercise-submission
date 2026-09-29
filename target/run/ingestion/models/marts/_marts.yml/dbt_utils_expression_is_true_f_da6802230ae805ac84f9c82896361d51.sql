
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(principal_usd_cbs IS NULL OR principal_usd IS NULL OR ABS(principal_usd - principal_usd_cbs) <= 5.00)


  
  
      
    ) dbt_internal_test