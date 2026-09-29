
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        ims_client_id, borrower_id
    from "ingestion"."main_intermediate"."int_client_identity_auto_matches"
    group by ims_client_id, borrower_id
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test