
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select borrower_id as from_field
    from "ingestion"."main_raw"."raw_cbs_loans"
    where borrower_id is not null
),

parent as (
    select borrower_id as to_field
    from "ingestion"."main_raw"."raw_cbs_borrowers"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test