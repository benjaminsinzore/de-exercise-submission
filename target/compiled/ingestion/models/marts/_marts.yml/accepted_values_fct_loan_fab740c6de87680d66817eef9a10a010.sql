
    
    

with all_values as (

    select
        fx_rate_source as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."fct_loan"
    group by fx_rate_source

)

select *
from all_values
where value_field not in (
    'cbs_fx_rate','fx_rates_official_on_or_before','no_rate'
)


