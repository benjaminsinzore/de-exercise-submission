
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        source_file, column_name
    from "ingestion"."main"."column_classification"
    group by source_file, column_name
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test