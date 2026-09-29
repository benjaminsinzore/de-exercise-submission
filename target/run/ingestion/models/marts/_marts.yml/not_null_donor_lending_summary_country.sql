
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select country
from "ingestion"."main_marts"."donor_lending_summary"
where country is null



  
  
      
    ) dbt_internal_test