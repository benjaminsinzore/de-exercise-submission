
    
    

with child as (
    select loan_id as from_field
    from "ingestion"."main_raw"."raw_cbs_repayments"
    where loan_id is not null
),

parent as (
    select loan_id as to_field
    from "ingestion"."main_raw"."raw_cbs_loans"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


