
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        coverage as value_field,
        count(*) as n_records

    from "ingestion"."main_intermediate"."int_loan_repayment_reconciliation"
    group by coverage

)

select *
from all_values
where value_field not in (
    'present','missing_in_control','missing_in_detail'
)



  
  
      
    ) dbt_internal_test