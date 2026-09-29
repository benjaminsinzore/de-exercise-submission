

SELECT
    country,
    month,
    currency,
    ctrl_loans_count,
    det_loans_count,
    loans_count_pass,
    ctrl_loans_amount,
    det_loans_amount,
    ROUND(100.0 * (det_loans_amount - ctrl_loans_amount)
          / NULLIF(ctrl_loans_amount, 0), 4) AS loans_amount_variance_pct,
    loans_amount_pass,
    ctrl_repay_count,
    det_repay_count,
    repayments_count_pass,
    ctrl_repay_amount,
    det_repay_amount,
    ROUND(100.0 * (det_repay_amount - ctrl_repay_amount)
          / NULLIF(ctrl_repay_amount, 0), 4) AS repayments_amount_variance_pct,
    repayments_amount_pass,
    row_pass,
    coverage
FROM "ingestion"."main_intermediate"."int_loan_repayment_reconciliation"