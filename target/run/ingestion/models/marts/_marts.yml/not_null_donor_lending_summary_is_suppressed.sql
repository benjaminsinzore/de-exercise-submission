
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_suppressed
from "ingestion"."main_marts"."donor_lending_summary"
where is_suppressed is null



  
  
      
    ) dbt_internal_test