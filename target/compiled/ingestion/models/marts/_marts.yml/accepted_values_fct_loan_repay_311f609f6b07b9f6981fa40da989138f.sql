
    
    

with all_values as (

    select
        coverage as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."fct_loan_repayment_reconciliation"
    group by coverage

)

select *
from all_values
where value_field not in (
    'present','missing_in_control','missing_in_detail'
)


