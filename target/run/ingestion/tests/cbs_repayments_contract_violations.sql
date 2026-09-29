
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select
    file_name,
    column_name,
    violation,
    declared_type,
    actual_type
from "ingestion"."main_raw"."raw_cbs_repayments_contract_check"
  
  
      
    ) dbt_internal_test