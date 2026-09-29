
    

    create  table
      "ingestion"."main"."dq1_arrival_check__dbt_tmp"
  
    
    as (
      





WITH actual AS (
    
    SELECT
        'ims_clients.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/ims_clients.csv',
            header = true,
            sample_size = -1
        )
    )
    UNION ALL
    
    SELECT
        'cbs_borrowers.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/cbs_borrowers.csv',
            header = true,
            sample_size = -1
        )
    )
    UNION ALL
    
    SELECT
        'cbs_loans.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/cbs_loans.csv',
            header = true,
            sample_size = -1
        )
    )
    UNION ALL
    
    SELECT
        'cbs_repayments_day1.csv' AS source_file,
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
    UNION ALL
    
    SELECT
        'cbs_repayments_day2.csv' AS source_file,
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
    UNION ALL
    
    SELECT
        'fx_rates.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/fx_rates.csv',
            header = true,
            sample_size = -1
        )
    )
    UNION ALL
    
    SELECT
        'cbs_control_totals.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/cbs_control_totals.csv',
            header = true,
            sample_size = -1
        )
    )
    UNION ALL
    
    SELECT
        'investment_screening.csv' AS source_file,
        column_name,
        column_type
    FROM (
        DESCRIBE
        SELECT *
        FROM read_csv_auto(
            'source/investment_screening.csv',
            header = true,
            sample_size = -1
        )
    )
    
    
),
classified AS (
    SELECT
        source_file,
        column_name,
        classification
    FROM "ingestion"."main"."column_classification"
),
unclassified AS (
    SELECT
        a.source_file,
        a.column_name,
        'unclassified_column' AS issue
    FROM actual a
    LEFT JOIN classified c
      ON a.source_file = c.source_file
     AND lower(a.column_name) = lower(c.column_name)
    WHERE c.column_name IS NULL
)
SELECT * FROM unclassified
    );
    
  