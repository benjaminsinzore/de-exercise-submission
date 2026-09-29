



select
    1
from "ingestion"."main_marts"."donor_lending_summary"

where not(loans_disbursed_count IS NOT NULL OR repayments_count IS NOT NULL)

