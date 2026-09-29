
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    enterprise_client_id as unique_field,
    count(*) as n_records

from "ingestion"."main_marts"."dim_enterprise_client"
where enterprise_client_id is not null
group by enterprise_client_id
having count(*) > 1



  
  
      
    ) dbt_internal_test