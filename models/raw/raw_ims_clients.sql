{{ config(materialized='table') }}

{% set excluded = excluded_columns('ims_clients.csv') %}
{% set minor_handling = var('minor_handling', 'tag') %}

WITH src AS (
    SELECT
        {% if excluded | length > 0 %}
        * EXCLUDE ({{ excluded | join(', ') }}),
        {% else %}
        *,
        {% endif %}
        {{ is_minor_expr('date_of_birth') }} AS is_minor
    FROM read_csv_auto(
        '{{ var("source_dir") }}/ims_clients.csv',
        header = true
    )
),
dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ims_client_id
            ORDER BY
                updated_at DESC NULLS LAST,
                registration_date DESC NULLS LAST
        ) AS rn
    FROM src
)
SELECT
    * EXCLUDE (rn),
    CASE
        WHEN is_minor IS NOT FALSE THEN 'restricted'
        ELSE 'personal'
    END AS data_class
FROM dedup
WHERE rn = 1
{% if minor_handling == 'quarantine' %}
  AND is_minor IS FALSE
{% endif %}