
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    borrower_id as unique_field,
    count(*) as n_records

from (select * from "ingestion"."main_intermediate"."int_client_identity_prepped" where source_system = 'cbs') dbt_subquery
where borrower_id is not null
group by borrower_id
having count(*) > 1



  
  
      
    ) dbt_internal_test