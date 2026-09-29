{{ config(materialized='table') }}

{% set pairs = [
    ('cbs_loans',            'raw_cbs_loans',            'clean_cbs_loans',            'quarantined_cbs_loans'),
    ('cbs_borrowers',        'raw_cbs_borrowers',        'clean_cbs_borrowers',        'quarantined_cbs_borrowers'),
    ('ims_clients',          'raw_ims_clients',          'clean_ims_clients',          'quarantined_ims_clients'),
    ('cbs_repayments',       'raw_cbs_repayments',       'clean_cbs_repayments',       'quarantined_cbs_repayments'),
    ('fx_rates',             'raw_fx_rates',             'clean_fx_rates',             'quarantined_fx_rates'),
    ('cbs_control_totals',   'raw_cbs_control_totals',   'clean_cbs_control_totals',   'quarantined_cbs_control_totals'),
    ('investment_screening', 'raw_investment_screening', 'clean_investment_screening', 'quarantined_investment_screening')
] %}

{% for short, raw, clean, quarantined in pairs %}
SELECT
    '{{ short }}' AS source,
    (SELECT count(*) FROM {{ ref(raw) }})         AS raw_count,
    (SELECT count(*) FROM {{ ref(clean) }})       AS clean_count,
    (SELECT count(*) FROM {{ ref(quarantined) }}) AS quarantined_count,
    (SELECT count(*) FROM {{ ref(clean) }})
      + (SELECT count(*) FROM {{ ref(quarantined) }})
        - (SELECT count(*) FROM {{ ref(raw) }})   AS balance_delta
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}