
    
    

with all_values as (

    select
        classification as value_field,
        count(*) as n_records

    from "ingestion"."main"."column_classification"
    group by classification

)

select *
from all_values
where value_field not in (
    'public','internal','personal','sensitive','restricted','excluded'
)


