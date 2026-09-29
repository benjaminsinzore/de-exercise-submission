
    

    create  table
      "ingestion"."main_marts"."donor_lending_summary__dbt_tmp"
  
    
    as (
      

WITH loans AS (
    SELECT
        country,
        CASE
            WHEN country IN ('KE','ET') THEN 'East Africa'
            WHEN country IN ('RW')      THEN 'Central Africa'
            WHEN country IN ('SS','TD') THEN 'Sahel'
            ELSE 'Other'
        END AS donor_region,
        date_trunc('month', disbursed_at) AS month,
        currency,
        COUNT(*) AS loans_disbursed_count,
        SUM(principal_local) AS loans_disbursed_amount_local,
        SUM(principal_usd) AS loans_disbursed_amount_usd,
        COUNT(DISTINCT enterprise_client_id) AS unique_borrowers
    FROM "ingestion"."main_marts"."fct_loan"
    WHERE is_minor_restricted = FALSE
    GROUP BY 1, 2, 3, 4
),

repayments AS (
    SELECT
        f.country,
        CASE
            WHEN f.country IN ('KE','ET') THEN 'East Africa'
            WHEN f.country IN ('RW')      THEN 'Central Africa'
            WHEN f.country IN ('SS','TD') THEN 'Sahel'
            ELSE 'Other'
        END AS donor_region,
        date_trunc('month', r.paid_at) AS month,
        f.currency,
        COUNT(DISTINCT r.txn_id) AS repayments_count,
        SUM(r.amount_net) AS repayments_amount_local
    FROM "ingestion"."main_raw"."raw_cbs_repayments" r
    JOIN "ingestion"."main_marts"."fct_loan" f ON r.loan_id = f.loan_id
    WHERE f.is_minor_restricted = FALSE
    GROUP BY 1, 2, 3, 4
),

combined AS (
    SELECT
        COALESCE(l.country, r.country) AS country,
        COALESCE(l.donor_region, r.donor_region) AS donor_region,
        COALESCE(l.month, r.month) AS month,
        COALESCE(l.currency, r.currency) AS currency,
        COALESCE(l.loans_disbursed_count, 0) AS loans_disbursed_count,
        COALESCE(l.loans_disbursed_amount_local, 0) AS loans_disbursed_amount_local,
        COALESCE(l.loans_disbursed_amount_usd, 0) AS loans_disbursed_amount_usd,
        COALESCE(l.unique_borrowers, 0) AS unique_borrowers,
        COALESCE(r.repayments_count, 0) AS repayments_count,
        COALESCE(r.repayments_amount_local, 0) AS repayments_amount_local
    FROM loans l
    FULL OUTER JOIN repayments r
      ON l.country = r.country
     AND l.month = r.month
     AND l.currency = r.currency
)

SELECT
    country,
    donor_region,
    month,
    currency,


    CASE WHEN loans_disbursed_count >= 5
         THEN loans_disbursed_count END AS loans_disbursed_count,
    CASE WHEN loans_disbursed_count >= 5
         THEN ROUND(loans_disbursed_amount_local, 2) END AS loans_disbursed_amount_local,
    CASE WHEN loans_disbursed_count >= 5
         THEN ROUND(loans_disbursed_amount_usd, 2) END AS loans_disbursed_amount_usd,
    CASE WHEN loans_disbursed_count >= 5
         THEN unique_borrowers END AS unique_borrowers,

    CASE WHEN repayments_count >= 5
         THEN repayments_count END AS repayments_count,
    CASE WHEN repayments_count >= 5
         THEN ROUND(repayments_amount_local, 2) END AS repayments_amount_local,

    CASE
        WHEN loans_disbursed_count < 5 OR repayments_count < 5 THEN TRUE
        ELSE FALSE
    END AS is_suppressed
FROM combined
    );
    
  