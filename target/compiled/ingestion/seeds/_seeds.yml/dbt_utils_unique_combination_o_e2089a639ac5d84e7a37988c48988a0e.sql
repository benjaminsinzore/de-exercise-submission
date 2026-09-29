





with validation_errors as (

    select
        source_file, column_name
    from "ingestion"."main"."column_classification"
    group by source_file, column_name
    having count(*) > 1

)

select *
from validation_errors


