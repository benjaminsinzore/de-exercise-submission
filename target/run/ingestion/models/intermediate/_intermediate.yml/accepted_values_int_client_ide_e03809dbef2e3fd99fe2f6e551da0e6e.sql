
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        review_reason as value_field,
        count(*) as n_records

    from "ingestion"."main_intermediate"."int_client_identity_review"
    group by review_reason

)

select *
from all_values
where value_field not in (
    'minor_requires_exact_id','ambiguous_ims','ambiguous_borrower','medium_confidence','high_confidence_but_not_auto','duplicate_ims_client_id','low_confidence'
)



  
  
      
    ) dbt_internal_test