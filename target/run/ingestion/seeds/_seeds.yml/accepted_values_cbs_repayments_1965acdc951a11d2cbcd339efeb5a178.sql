
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        requirement as value_field,
        count(*) as n_records

    from "ingestion"."main"."cbs_repayments_contract"
    group by requirement

)

select *
from all_values
where value_field not in (
    'required','optional'
)



  
  
      
    ) dbt_internal_test