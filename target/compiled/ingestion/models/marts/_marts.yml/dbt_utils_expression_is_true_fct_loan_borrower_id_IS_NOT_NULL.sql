



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(borrower_id IS NOT NULL)

