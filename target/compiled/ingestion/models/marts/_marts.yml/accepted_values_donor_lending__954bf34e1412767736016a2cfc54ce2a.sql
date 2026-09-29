
    
    

with all_values as (

    select
        currency as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."donor_lending_summary"
    group by currency

)

select *
from all_values
where value_field not in (
    'KES','ETB','RWF','SSP','XAF'
)


