
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(borrower_id IS NOT NULL)


  
  
      
    ) dbt_internal_test