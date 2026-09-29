{{ config(materialized='table') }}

{% set excluded = excluded_columns('cbs_loans.csv') %}

WITH src AS (
    SELECT
        {% if excluded | length > 0 %}
        * EXCLUDE ({{ excluded | join(', ') }})
        {% else %}
        *
        {% endif %}
    FROM read_csv_auto(
        '{{ var("source_dir") }}/cbs_loans.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY disbursed_at DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT * EXCLUDE (rn)
FROM dedup
WHERE rn = 1