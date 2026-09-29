
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        classification as value_field,
        count(*) as n_records

    from "ingestion"."main"."column_classification"
    group by classification

)

select *
from all_values
where value_field not in (
    'public','internal','personal','sensitive','restricted','excluded'
)



  
  
      
    ) dbt_internal_test