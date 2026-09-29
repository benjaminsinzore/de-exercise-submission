{% test no_excluded_columns(model, excluded=[]) %}

WITH columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = '{{ model.schema }}'
      AND table_name = '{{ model.name }}'
)
SELECT column_name
FROM columns
WHERE column_name IN (
    {% for col in excluded %}
    '{{ col }}'{% if not loop.last %},{% endif %}
    {% endfor %}
)

{% endtest %}