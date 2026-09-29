select
    file_name,
    column_name,
    violation,
    declared_type,
    actual_type
from {{ ref('raw_cbs_repayments_contract_check') }}