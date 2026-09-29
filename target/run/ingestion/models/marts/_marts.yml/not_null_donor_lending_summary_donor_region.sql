
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select donor_region
from "ingestion"."main_marts"."donor_lending_summary"
where donor_region is null



  
  
      
    ) dbt_internal_test