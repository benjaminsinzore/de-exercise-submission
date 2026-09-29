
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select source_file
from "ingestion"."main"."column_classification"
where source_file is null



  
  
      
    ) dbt_internal_test