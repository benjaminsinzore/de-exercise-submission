
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select declared_type
from "ingestion"."main"."cbs_repayments_contract"
where declared_type is null



  
  
      
    ) dbt_internal_test