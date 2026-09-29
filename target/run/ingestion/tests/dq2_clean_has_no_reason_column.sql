
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  


select
    'clean_cbs_loans' as source,
    column_name
from information_schema.columns
where table_name = 'clean_cbs_loans'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_cbs_borrowers' as source,
    column_name
from information_schema.columns
where table_name = 'clean_cbs_borrowers'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_ims_clients' as source,
    column_name
from information_schema.columns
where table_name = 'clean_ims_clients'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_cbs_repayments' as source,
    column_name
from information_schema.columns
where table_name = 'clean_cbs_repayments'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_fx_rates' as source,
    column_name
from information_schema.columns
where table_name = 'clean_fx_rates'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_cbs_control_totals' as source,
    column_name
from information_schema.columns
where table_name = 'clean_cbs_control_totals'
  and column_name = 'quarantine_reason'
UNION ALL

select
    'clean_investment_screening' as source,
    column_name
from information_schema.columns
where table_name = 'clean_investment_screening'
  and column_name = 'quarantine_reason'


  
  
      
    ) dbt_internal_test