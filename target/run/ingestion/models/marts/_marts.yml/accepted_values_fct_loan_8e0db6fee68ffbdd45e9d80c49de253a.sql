
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        cbs_rate_convention as value_field,
        count(*) as n_records

    from (select * from "ingestion"."main_marts"."fct_loan" where cbs_rate_convention is not null) dbt_subquery
    group by cbs_rate_convention

)

select *
from all_values
where value_field not in (
    'units_per_usd','usd_per_unit'
)



  
  
      
    ) dbt_internal_test