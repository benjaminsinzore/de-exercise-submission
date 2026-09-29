


select
    'quarantined_cbs_loans' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_cbs_loans"
where quarantine_reason is null
union all

select
    'quarantined_cbs_borrowers' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_cbs_borrowers"
where quarantine_reason is null
union all

select
    'quarantined_ims_clients' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_ims_clients"
where quarantine_reason is null
union all

select
    'quarantined_cbs_repayments' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_cbs_repayments"
where quarantine_reason is null
union all

select
    'quarantined_fx_rates' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_fx_rates"
where quarantine_reason is null
union all

select
    'quarantined_cbs_control_totals' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_cbs_control_totals"
where quarantine_reason is null
union all

select
    'quarantined_investment_screening' as source,
    quarantine_reason,
    quarantined_at
from "ingestion"."main"."quarantined_investment_screening"
where quarantine_reason is null

