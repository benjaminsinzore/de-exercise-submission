
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

WITH columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'main_marts'
      AND table_name = 'donor_lending_summary'
)
SELECT column_name
FROM columns
WHERE column_name IN (
    
    'borrower_id',
    
    'loan_id',
    
    'enterprise_client_id',
    
    'loan_officer'
    
)


  
  
      
    ) dbt_internal_test