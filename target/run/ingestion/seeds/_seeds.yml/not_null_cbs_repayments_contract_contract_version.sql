
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select contract_version
from "ingestion"."main"."cbs_repayments_contract"
where contract_version is null



  
  
      
    ) dbt_internal_test