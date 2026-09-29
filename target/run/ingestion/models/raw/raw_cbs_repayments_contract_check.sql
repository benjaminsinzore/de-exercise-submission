
    

    create  table
      "ingestion"."main_raw"."raw_cbs_repayments_contract_check__dbt_tmp"
  
    
    as (
      




WITH

actual_1 AS (
    SELECT
        'cbs_repayments_day1.csv' AS file_name,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/cbs_repayments_day1.csv',
            header = true,
            sample_size = -1
        )
    )
),

actual_2 AS (
    SELECT
        'cbs_repayments_day2.csv' AS file_name,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/cbs_repayments_day2.csv',
            header = true,
            sample_size = -1
        )
    )
),

actual AS (
    
    SELECT * FROM actual_1
    UNION ALL
    
    SELECT * FROM actual_2
    
    
),
declared AS (
    SELECT
        file_name,
        column_name,
        declared_type,
        requirement,
        canonical_name
    FROM "ingestion"."main"."cbs_repayments_contract"
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
    );
    
  