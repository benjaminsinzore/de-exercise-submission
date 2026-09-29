





with validation_errors as (

    select
        file_name, column_name
    from "ingestion"."main"."cbs_repayments_contract"
    group by file_name, column_name
    having count(*) > 1

)

select *
from validation_errors


