{{ config(materialized='table') }}

{% set excluded = excluded_columns('investment_screening.csv') %}

WITH src AS (
    SELECT
        {% if excluded | length > 0 %}
        * EXCLUDE ({{ excluded | join(', ') }}),
        {% else %}
        *,
        {% endif %}
        NULL::BOOLEAN AS is_minor,
        'unknown' AS minor_status,
        'personal' AS data_class
    FROM read_csv_auto(
        '{{ var("source_dir") }}/investment_screening.csv',
        header = true
    )
)
SELECT DISTINCT *
FROM src