select
    source,
    raw_count,
    clean_count,
    quarantined_count,
    balance_delta
from "ingestion"."main"."dq2_row_balance"
where raw_count <> clean_count + quarantined_count