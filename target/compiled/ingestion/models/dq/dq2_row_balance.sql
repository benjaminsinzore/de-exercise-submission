




SELECT
    'cbs_loans' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_loans")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_loans")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_loans") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_loans")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_loans")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_loans")   AS balance_delta
UNION ALL

SELECT
    'cbs_borrowers' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_borrowers")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_borrowers")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_borrowers") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_borrowers")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_borrowers")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_borrowers")   AS balance_delta
UNION ALL

SELECT
    'ims_clients' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_ims_clients")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_ims_clients")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_ims_clients") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_ims_clients")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_ims_clients")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_ims_clients")   AS balance_delta
UNION ALL

SELECT
    'cbs_repayments' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_repayments")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_repayments")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_repayments") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_repayments")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_repayments")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_repayments")   AS balance_delta
UNION ALL

SELECT
    'fx_rates' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_fx_rates")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_fx_rates")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_fx_rates") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_fx_rates")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_fx_rates")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_fx_rates")   AS balance_delta
UNION ALL

SELECT
    'cbs_control_totals' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_control_totals")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_control_totals")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_control_totals") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_cbs_control_totals")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_cbs_control_totals")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_cbs_control_totals")   AS balance_delta
UNION ALL

SELECT
    'investment_screening' AS source,
    (SELECT count(*) FROM "ingestion"."main_raw"."raw_investment_screening")         AS raw_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_investment_screening")       AS clean_count,
    (SELECT count(*) FROM "ingestion"."main"."quarantined_investment_screening") AS quarantined_count,
    (SELECT count(*) FROM "ingestion"."main"."clean_investment_screening")
      + (SELECT count(*) FROM "ingestion"."main"."quarantined_investment_screening")
        - (SELECT count(*) FROM "ingestion"."main_raw"."raw_investment_screening")   AS balance_delta

