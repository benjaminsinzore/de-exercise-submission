

WITH loans AS (
    SELECT
        CASE
            WHEN upper(country) IN ('KE','KENYA') THEN 'KE'
            WHEN upper(country) IN ('ET','ETHIOPIA') THEN 'ET'
            WHEN upper(country) IN ('RW','RWANDA') THEN 'RW'
            WHEN upper(country) IN ('SS','SOUTH SUDAN') THEN 'SS'
            WHEN upper(country) IN ('TD','CHAD') THEN 'TD'
            ELSE upper(country)
        END AS country,
        date_trunc('month', try_cast(disbursed_at AS TIMESTAMP)) AS month,
        CASE
            WHEN upper(currency) IN ('KES','KSH') THEN 'KES'
            WHEN upper(currency) IN ('ETB') THEN 'ETB'
            WHEN upper(currency) IN ('RWF') THEN 'RWF'
            WHEN upper(currency) IN ('SSP') THEN 'SSP'
            WHEN upper(currency) IN ('XAF') THEN 'XAF'
            ELSE upper(currency)
        END AS currency,
        COUNT(*) AS loans_disbursed_count,
        SUM(TRY_CAST(regexp_replace(principal, '[^0-9.\-]', '', 'g') AS DOUBLE)) AS loans_disbursed_amount
    FROM "ingestion"."main_raw"."raw_cbs_loans"
    GROUP BY 1, 2, 3
),

repayments AS (
    SELECT
        CASE
            WHEN upper(l.country) IN ('KE','KENYA') THEN 'KE'
            WHEN upper(l.country) IN ('ET','ETHIOPIA') THEN 'ET'
            WHEN upper(l.country) IN ('RW','RWANDA') THEN 'RW'
            WHEN upper(l.country) IN ('SS','SOUTH SUDAN') THEN 'SS'
            WHEN upper(l.country) IN ('TD','CHAD') THEN 'TD'
            ELSE upper(l.country)
        END AS country,
        date_trunc('month', try_cast(r.paid_at AS TIMESTAMP)) AS month,
        CASE
            WHEN upper(r.currency) IN ('KES','KSH') THEN 'KES'
            WHEN upper(r.currency) IN ('ETB') THEN 'ETB'
            WHEN upper(r.currency) IN ('RWF') THEN 'RWF'
            WHEN upper(r.currency) IN ('SSP') THEN 'SSP'
            WHEN upper(r.currency) IN ('XAF') THEN 'XAF'
            ELSE upper(r.currency)
        END AS currency,
        COUNT(DISTINCT r.txn_id) AS repayments_count,
        SUM(r.amount_paid) AS repayments_amount
    FROM (
        SELECT txn_id, loan_id, paid_at, amount_paid, currency
        FROM "ingestion"."main_raw"."raw_cbs_repayments"
        QUALIFY ROW_NUMBER() OVER (PARTITION BY txn_id ORDER BY paid_at DESC) = 1
    ) r
    JOIN "ingestion"."main_raw"."raw_cbs_loans" l ON r.loan_id = l.loan_id
    GROUP BY 1, 2, 3
)

SELECT
    COALESCE(l.country, r.country) AS country,
    COALESCE(l.month, r.month) AS month,
    COALESCE(l.currency, r.currency) AS currency,
    COALESCE(l.loans_disbursed_count, 0) AS loans_disbursed_count,
    COALESCE(l.loans_disbursed_amount, 0) AS loans_disbursed_amount,
    COALESCE(r.repayments_count, 0) AS repayments_count,
    COALESCE(r.repayments_amount, 0) AS repayments_amount
FROM loans l
FULL OUTER JOIN repayments r
  ON l.country = r.country
 AND l.month = r.month
 AND l.currency = r.currency