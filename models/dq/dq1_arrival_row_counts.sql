{{ config(materialized='table') }}

{% set sources = [
    'ims_clients.csv',
    'cbs_borrowers.csv',
    'cbs_loans.csv',
    'cbs_repayments_day1.csv',
    'cbs_repayments_day2.csv',
    'fx_rates.csv',
    'cbs_control_totals.csv',
    'investment_screening.csv'
] %}

{% set source_dir = var("source_dir") %}

{% for filename in sources %}
SELECT
    '{{ filename }}' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    '{{ source_dir }}/{{ filename }}',
    header = true,
    sample_size = -1
)
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}