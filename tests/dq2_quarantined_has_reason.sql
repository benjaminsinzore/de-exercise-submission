{% set models = [
    'quarantined_cbs_loans',
    'quarantined_cbs_borrowers',
    'quarantined_ims_clients',
    'quarantined_cbs_repayments',
    'quarantined_fx_rates',
    'quarantined_cbs_control_totals',
    'quarantined_investment_screening'
] %}

{% for model in models %}
select
    '{{ model }}' as source,
    quarantine_reason,
    quarantined_at
from {{ ref(model) }}
where quarantine_reason is null
{% if not loop.last %}union all{% endif %}
{% endfor %}