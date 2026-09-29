{{ config(materialized='table') }}

{% set excluded = excluded_columns('fx_rates.csv') %}

WITH src AS (
    SELECT
        {% if excluded | length > 0 %}
        * EXCLUDE ({{ excluded | join(', ') }})
        {% else %}
        *
        {% endif %}
    FROM read_csv_auto(
        '{{ var("source_dir") }}/fx_rates.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY currency, rate_date, rate_type, source
            ORDER BY published_at DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT * EXCLUDE (rn)
FROM dedup
WHERE rn = 1