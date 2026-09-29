
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    borrower_id as unique_field,
    count(*) as n_records

from "ingestion"."main_raw"."raw_cbs_borrowers"
where borrower_id is not null
group by borrower_id
having count(*) > 1



  
  
      
    ) dbt_internal_test