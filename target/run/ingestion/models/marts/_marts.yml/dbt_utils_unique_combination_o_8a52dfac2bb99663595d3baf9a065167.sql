
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        country, month, currency
    from "ingestion"."main_marts"."donor_lending_summary"
    group by country, month, currency
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test