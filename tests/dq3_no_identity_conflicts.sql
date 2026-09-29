select
    enterprise_client_id,
    ims_client_id,
    borrower_id,
    conflict,
    severity,
    ims_value,
    cbs_value
from {{ ref('dq3_identity_conflicts') }}
where severity = 'high'