
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select review_reason
from "ingestion"."main_intermediate"."int_client_identity_review"
where review_reason is null



  
  
      
    ) dbt_internal_test