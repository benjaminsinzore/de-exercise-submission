
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

WITH columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'main_marts'
      AND table_name = 'fct_loan'
)
SELECT column_name
FROM columns
WHERE column_name IN (
    
    'fingerprint_template_ref',
    
    'id_number',
    
    'id_document_number',
    
    'phone_1',
    
    'phone_2',
    
    'mobile_no',
    
    'first_name',
    
    'last_name'
    
)


  
  
      
    ) dbt_internal_test