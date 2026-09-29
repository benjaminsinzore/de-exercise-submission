
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ims_client_id
from "ingestion"."main_raw"."raw_ims_clients"
where ims_client_id is null



  
  
      
    ) dbt_internal_test