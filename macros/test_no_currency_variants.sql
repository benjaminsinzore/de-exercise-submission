{% test no_currency_variants(model, column_name, allowed=[]) %}

SELECT DISTINCT {{ column_name }} AS bad_value
FROM {{ model }}
WHERE {{ column_name }} NOT IN (
    {% for v in allowed %}
    '{{ v }}'{% if not loop.last %},{% endif %}
    {% endfor %}
)

{% endtest %}