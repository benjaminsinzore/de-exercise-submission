
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        country as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."fct_loan"
    group by country

)

select *
from all_values
where value_field not in (
    'KE','ET','RW','SS','TD'
)



  
  
      
    ) dbt_internal_test