
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select * from "ingestion"."main"."dq1_arrival_check"
  
  
      
    ) dbt_internal_test