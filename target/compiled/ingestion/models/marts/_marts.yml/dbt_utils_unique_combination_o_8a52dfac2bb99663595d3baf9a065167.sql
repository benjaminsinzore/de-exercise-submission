





with validation_errors as (

    select
        country, month, currency
    from "ingestion"."main_marts"."donor_lending_summary"
    group by country, month, currency
    having count(*) > 1

)

select *
from validation_errors


