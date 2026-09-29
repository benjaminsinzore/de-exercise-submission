
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        donor_region as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."donor_lending_summary"
    group by donor_region

)

select *
from all_values
where value_field not in (
    'East Africa','Central Africa','Sahel','Other'
)



  
  
      
    ) dbt_internal_test