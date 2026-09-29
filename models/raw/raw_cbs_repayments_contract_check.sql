{{ config(materialized='table') }}

{% set source_dir = var("source_dir") %}
{% set contract_files = [
    'cbs_repayments_day1.csv',
    'cbs_repayments_day2.csv'
] %}

WITH
{% for file_name in contract_files %}
actual_{{ loop.index }} AS (
    SELECT
        '{{ file_name }}' AS file_name,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            '{{ source_dir }}/{{ file_name }}',
            header = true,
            sample_size = -1
        )
    )
),
{% endfor %}
actual AS (
    {% for file_name in contract_files %}
    SELECT * FROM actual_{{ loop.index }}
    {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
),
declared AS (
    SELECT
        file_name,
        column_name,
        declared_type,
        requirement,
        canonical_name
    FROM {{ ref('cbs_repayments_contract') }}
),
missing_required AS (
    SELECT
        d.file_name,
        d.column_name,
        'missing_required' AS violation,
        d.declared_type AS declared_type,
        NULL AS actual_type
    FROM declared d
    LEFT JOIN actual a
      ON d.file_name = a.file_name
     AND lower(d.column_name) = lower(a.column_name)
    WHERE d.requirement = 'required'
      AND a.column_name IS NULL
),
undeclared AS (
    SELECT
        a.file_name,
        a.column_name,
        'undeclared_column' AS violation,
        NULL AS declared_type,
        a.column_type AS actual_type
    FROM actual a
    LEFT JOIN declared d
      ON a.file_name = d.file_name
     AND lower(a.column_name) = lower(d.column_name)
    WHERE d.column_name IS NULL
),
type_mismatch AS (
    SELECT
        d.file_name,
        d.column_name,
        'type_mismatch' AS violation,
        d.declared_type,
        a.column_type AS actual_type
    FROM declared d
    JOIN actual a
      ON d.file_name = a.file_name
     AND lower(d.column_name) = lower(a.column_name)
    WHERE upper(d.declared_type) <> upper(a.column_type)
),
violations AS (
    SELECT * FROM missing_required
    UNION ALL
    SELECT * FROM undeclared
    UNION ALL
    SELECT * FROM type_mismatch
)
SELECT
    file_name,
    column_name,
    violation,
    declared_type,
    actual_type
FROM violations
ORDER BY file_name, violation, column_name