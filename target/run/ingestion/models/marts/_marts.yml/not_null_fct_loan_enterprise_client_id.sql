
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select enterprise_client_id
from "ingestion"."main_marts"."fct_loan"
where enterprise_client_id is null



  
  
      
    ) dbt_internal_test