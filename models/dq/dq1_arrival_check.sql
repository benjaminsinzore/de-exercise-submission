{{ config(materialized='table') }}

{% set sources = {
    'ims_clients.csv': 'ims_clients.csv',
    'cbs_borrowers.csv': 'cbs_borrowers.csv',
    'cbs_loans.csv': 'cbs_loans.csv',
    'cbs_repayments_day1.csv': 'cbs_repayments_day1.csv',
    'cbs_repayments_day2.csv': 'cbs_repayments_day2.csv',
    'fx_rates.csv': 'fx_rates.csv',
    'cbs_control_totals.csv': 'cbs_control_totals.csv',
    'investment_screening.csv': 'investment_screening.csv'
} %}

{% set source_dir = var("source_dir") %}

WITH actual AS (
    {% for logical, filename in sources.items() %}
    SELECT
        '{{ filename }}' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            '{{ source_dir }}/{{ filename }}',
            header = true,
            sample_size = -1
        )
    )
    {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
),
classified AS (
    SELECT
        source_file,
        column_name,
        classification
    FROM {{ ref('column_classification') }}
),
unclassified AS (
    SELECT
        a.source_file,
        a.column_name,
        'unclassified_column' AS issue
    FROM actual a
    LEFT JOIN classified c
      ON a.source_file = c.source_file
     AND lower(a.column_name) = lower(c.column_name)
    WHERE c.column_name IS NULL
)
SELECT * FROM unclassified