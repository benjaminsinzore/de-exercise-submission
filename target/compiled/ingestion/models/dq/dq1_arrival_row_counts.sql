






SELECT
    'ims_clients.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/ims_clients.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'cbs_borrowers.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/cbs_borrowers.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'cbs_loans.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/cbs_loans.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'cbs_repayments_day1.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/cbs_repayments_day1.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'cbs_repayments_day2.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/cbs_repayments_day2.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'fx_rates.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/fx_rates.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'cbs_control_totals.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/cbs_control_totals.csv',
    header = true,
    sample_size = -1
)
UNION ALL

SELECT
    'investment_screening.csv' AS source_file,
    count(*) AS row_count,
    current_timestamp AS recorded_at
FROM read_csv_auto(
    'source/investment_screening.csv',
    header = true,
    sample_size = -1
)

