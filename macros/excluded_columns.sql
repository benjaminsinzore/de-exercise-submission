{% macro excluded_columns(target_filename) %}
    {% if not execute %}
        {{ return([]) }}
    {% endif %}

    {% set path = var('classification_path', 'source/classification.yaml') %}

    {% set result = run_query(
        "SELECT content FROM read_text('" ~ path ~ "')"
    ) %}

    {% if not result or result.rows | length == 0 %}
        {{ exceptions.raise_compiler_error(
            "Could not read classification file at '" ~ path ~ "'"
        ) }}
    {% endif %}

    {% set parsed = fromyaml(result.rows[0][0]) %}
    
    {# Extract the column configuration dictionary for our target file #}
    {% set file_config = parsed.get('files', {}).get(target_filename, {}) %}
    
    {# Collect only the columns that are explicitly marked as 'excluded' #}
    {% set excluded_list = [] %}
    {% for col_name, classification in file_config.items() %}
        {% if classification == 'excluded' %}
            {% do excluded_list.append(col_name) %}
        {% endif %}
    {% endfor %}

    {{ return(excluded_list) }}
{% endmacro %}
