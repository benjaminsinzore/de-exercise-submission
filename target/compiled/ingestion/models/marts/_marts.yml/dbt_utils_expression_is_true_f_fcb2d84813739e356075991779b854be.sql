



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(principal_local IS NULL OR principal_local > 0)

