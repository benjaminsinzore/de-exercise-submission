
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    txn_id as unique_field,
    count(*) as n_records

from "ingestion"."main_raw"."raw_cbs_repayments"
where txn_id is not null
group by txn_id
having count(*) > 1



  
  
      
    ) dbt_internal_test