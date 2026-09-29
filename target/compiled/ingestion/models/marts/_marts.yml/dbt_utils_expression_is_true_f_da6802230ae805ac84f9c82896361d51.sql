



select
    1
from "ingestion"."main_marts"."fct_loan"

where not(principal_usd_cbs IS NULL OR principal_usd IS NULL OR ABS(principal_usd - principal_usd_cbs) <= 5.00)

