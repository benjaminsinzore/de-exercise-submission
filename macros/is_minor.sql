{% macro is_minor_expr(dob_col, as_of_col=none) %}
    {%- set ref = as_of_col if as_of_col is not none else 'current_date' -%}
    date_diff(
        'year',
        COALESCE(
            TRY_CAST({{ dob_col }} AS DATE),
            TRY_STRPTIME(CAST({{ dob_col }} AS VARCHAR), '%d/%m/%Y'),
            TRY_STRPTIME(CAST({{ dob_col }} AS VARCHAR), '%d-%m-%Y'),
            TRY_STRPTIME(CAST({{ dob_col }} AS VARCHAR), '%Y/%m/%d'),
            TRY_STRPTIME(CAST({{ dob_col }} AS VARCHAR), '%d.%m.%Y'),
            TRY_STRPTIME(CAST({{ dob_col }} AS VARCHAR), '%m/%d/%Y')
        ),
        {{ ref }}
    ) < 18
{% endmacro %}