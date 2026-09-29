{{ config(materialized='table') }}

{% set pairs = [
    ('cbs_loans',            'quarantined_cbs_loans'),
    ('cbs_borrowers',        'quarantined_cbs_borrowers'),
    ('ims_clients',          'quarantined_ims_clients'),
    ('cbs_repayments',       'quarantined_cbs_repayments'),
    ('fx_rates',             'quarantined_fx_rates'),
    ('cbs_control_totals',   'quarantined_cbs_control_totals'),
    ('investment_screening', 'quarantined_investment_screening')
] %}

{% for short, model in pairs %}
SELECT
    '{{ short }}' AS source,
    quarantine_reason,
    count(*) AS record_count,
    min(quarantined_at) AS first_seen_at,
    max(quarantined_at) AS last_seen_at
FROM {{ ref(model) }}
GROUP BY 1, 2
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}