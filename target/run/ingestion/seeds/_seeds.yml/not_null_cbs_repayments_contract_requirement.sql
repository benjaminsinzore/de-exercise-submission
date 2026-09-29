
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select requirement
from "ingestion"."main"."cbs_repayments_contract"
where requirement is null



  
  
      
    ) dbt_internal_test