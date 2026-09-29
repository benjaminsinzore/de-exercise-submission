



select
    1
from "ingestion"."main_marts"."donor_lending_summary"

where not((loans_disbursed_count IS NULL OR loans_disbursed_count >= 5) AND (repayments_count IS NULL OR repayments_count >= 5))

