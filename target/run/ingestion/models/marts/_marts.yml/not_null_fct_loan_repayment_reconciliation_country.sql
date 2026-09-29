
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country
from "ingestion"."main_marts"."fct_loan_repayment_reconciliation"
where country is null



  
  
      
    ) dbt_internal_test