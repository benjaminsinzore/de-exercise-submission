
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fx_rate_source
from "ingestion"."main_marts"."fct_loan"
where fx_rate_source is null



  
  
      
    ) dbt_internal_test