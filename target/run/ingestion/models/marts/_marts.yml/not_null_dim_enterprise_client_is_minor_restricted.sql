
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_minor_restricted
from "ingestion"."main_marts"."dim_enterprise_client"
where is_minor_restricted is null



  
  
      
    ) dbt_internal_test