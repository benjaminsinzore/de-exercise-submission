
    

    create  table
      "ingestion"."main_intermediate"."int_loan_repayment_reconciliation__dbt_tmp"
  
    
    as (
      

WITH detail AS (
    SELECT * FROM "ingestion"."main_intermediate"."int_loan_repayment_detail_totals"
),
control AS (
    SELECT
        CASE
            WHEN upper(country) IN ('KE','KENYA') THEN 'KE'
            WHEN upper(country) IN ('ET','ETHIOPIA') THEN 'ET'
            WHEN upper(country) IN ('RW','RWANDA') THEN 'RW'
            WHEN upper(country) IN ('SS','SOUTH SUDAN') THEN 'SS'
            WHEN upper(country) IN ('TD','CHAD') THEN 'TD'
            ELSE upper(country)
        END AS country,
        try_cast(month || '-01' AS DATE) AS month,
        CASE
            WHEN upper(currency) IN ('KES','KSH') THEN 'KES'
            WHEN upper(currency) IN ('ETB') THEN 'ETB'
            WHEN upper(currency) IN ('RWF') THEN 'RWF'
            WHEN upper(currency) IN ('SSP') THEN 'SSP'
            WHEN upper(currency) IN ('XAF') THEN 'XAF'
            ELSE upper(currency)
        END AS currency,
        loans_disbursed_count,
        loans_disbursed_amount,
        repayments_count,
        repayments_amount
    FROM "ingestion"."main_raw"."raw_cbs_control_totals"
),
joined AS (
    SELECT
        COALESCE(c.country, d.country) AS country,
        COALESCE(c.month, d.month) AS month,
        COALESCE(c.currency, d.currency) AS currency,
        c.loans_disbursed_count AS ctrl_loans_count,
        d.loans_disbursed_count AS det_loans_count,
        c.loans_disbursed_amount AS ctrl_loans_amount,
        d.loans_disbursed_amount AS det_loans_amount,
        c.repayments_count AS ctrl_repay_count,
        d.repayments_count AS det_repay_count,
        c.repayments_amount AS ctrl_repay_amount,
        d.repayments_amount AS det_repay_amount
    FROM control c
    FULL OUTER JOIN detail d
      ON c.country = d.country AND c.month = d.month AND c.currency = d.currency
)
SELECT
    j.country,
    j.month,
    j.currency,

    j.ctrl_loans_count,
    j.det_loans_count,
    (COALESCE(j.ctrl_loans_count,0) = COALESCE(j.det_loans_count,0)) AS loans_count_pass,

    j.ctrl_loans_amount,
    j.det_loans_amount,
    CASE
        WHEN j.ctrl_loans_amount IS NULL OR j.det_loans_amount IS NULL THEN FALSE
        WHEN ABS(j.det_loans_amount - j.ctrl_loans_amount)
             <= GREATEST(1.00, 0.005 * ABS(j.ctrl_loans_amount)) THEN TRUE
        ELSE FALSE
    END AS loans_amount_pass,

    j.ctrl_repay_count,
    j.det_repay_count,
    (COALESCE(j.ctrl_repay_count,0) = COALESCE(j.det_repay_count,0)) AS repayments_count_pass,

    j.ctrl_repay_amount,
    j.det_repay_amount,
    CASE
        WHEN j.ctrl_repay_amount IS NULL OR j.det_repay_amount IS NULL THEN FALSE
        WHEN ABS(j.det_repay_amount - j.ctrl_repay_amount)
             <= GREATEST(1.00, 0.005 * ABS(j.ctrl_repay_amount)) THEN TRUE
        ELSE FALSE
    END AS repayments_amount_pass,

    (
        (COALESCE(j.ctrl_loans_count,0) = COALESCE(j.det_loans_count,0))
        AND (COALESCE(j.ctrl_repay_count,0) = COALESCE(j.det_repay_count,0))
        AND j.ctrl_loans_amount IS NOT NULL AND j.det_loans_amount IS NOT NULL
        AND ABS(j.det_loans_amount - j.ctrl_loans_amount)
            <= GREATEST(1.00, 0.005 * ABS(j.ctrl_loans_amount))
        AND j.ctrl_repay_amount IS NOT NULL AND j.det_repay_amount IS NOT NULL
        AND ABS(j.det_repay_amount - j.ctrl_repay_amount)
            <= GREATEST(1.00, 0.005 * ABS(j.ctrl_repay_amount))
    ) AS row_pass,

    CASE
        WHEN j.ctrl_loans_count IS NULL AND j.ctrl_repay_count IS NULL
             AND j.ctrl_loans_amount IS NULL AND j.ctrl_repay_amount IS NULL
            THEN 'missing_in_control'
        WHEN j.det_loans_count IS NULL AND j.det_repay_count IS NULL
             AND j.det_loans_amount IS NULL AND j.det_repay_amount IS NULL
            THEN 'missing_in_detail'
        ELSE 'present'
    END AS coverage
FROM joined j
    );
    
  