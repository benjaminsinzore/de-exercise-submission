
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        declared_type as value_field,
        count(*) as n_records

    from "ingestion"."main"."cbs_repayments_contract"
    group by declared_type

)

select *
from all_values
where value_field not in (
    'VARCHAR','DOUBLE','BIGINT','INTEGER','BOOLEAN','TIMESTAMP','TIMESTAMP WITH TIME ZONE'
)



  
  
      
    ) dbt_internal_test