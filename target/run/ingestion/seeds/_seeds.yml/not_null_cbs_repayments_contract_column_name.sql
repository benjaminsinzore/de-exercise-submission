
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select column_name
from "ingestion"."main"."cbs_repayments_contract"
where column_name is null



  
  
      
    ) dbt_internal_test