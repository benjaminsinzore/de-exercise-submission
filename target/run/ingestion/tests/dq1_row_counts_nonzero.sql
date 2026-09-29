
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select * from "ingestion"."main"."dq1_arrival_row_counts"
where row_count = 0
  
  
      
    ) dbt_internal_test