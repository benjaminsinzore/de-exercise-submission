
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "ingestion"."main_marts"."donor_lending_summary"

where not(loans_disbursed_count IS NOT NULL OR repayments_count IS NOT NULL)


  
  
      
    ) dbt_internal_test