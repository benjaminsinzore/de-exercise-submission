{% set models = [
    'clean_cbs_loans',
    'clean_cbs_borrowers',
    'clean_ims_clients',
    'clean_cbs_repayments',
    'clean_fx_rates',
    'clean_cbs_control_totals',
    'clean_investment_screening'
] %}

{% for model in models %}
select
    '{{ model }}' as source,
    column_name
from information_schema.columns
where table_name = '{{ model }}'
  and column_name = 'quarantine_reason'
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}