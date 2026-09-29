
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select currency
from "ingestion"."main_marts"."fct_loan_repayment_reconciliation"
where currency is null



  
  
      
    ) dbt_internal_test