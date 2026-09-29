
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(principal_local IS NULL OR principal_local > 0)


  
  
      
    ) dbt_internal_test