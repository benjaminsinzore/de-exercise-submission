
    
    

with all_values as (

    select
        country as value_field,
        count(*) as n_records

    from "ingestion"."main_marts"."donor_lending_summary"
    group by country

)

select *
from all_values
where value_field not in (
    'KE','ET','RW','SS','TD'
)


