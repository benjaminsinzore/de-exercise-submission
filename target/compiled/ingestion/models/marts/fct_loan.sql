

WITH loans AS (
    SELECT
        loan_id,
        borrower_id,
        CASE
            WHEN upper(country) IN ('KE','KENYA') THEN 'KE'
            WHEN upper(country) IN ('ET','ETHIOPIA') THEN 'ET'
            WHEN upper(country) IN ('RW','RWANDA') THEN 'RW'
            WHEN upper(country) IN ('SS','SOUTH SUDAN') THEN 'SS'
            WHEN upper(country) IN ('TD','CHAD') THEN 'TD'
            ELSE upper(country)
        END AS country,
        product,
        CASE
            WHEN upper(currency) IN ('KES','KSH') THEN 'KES'
            WHEN upper(currency) IN ('ETB') THEN 'ETB'
            WHEN upper(currency) IN ('RWF') THEN 'RWF'
            WHEN upper(currency) IN ('SSP') THEN 'SSP'
            WHEN upper(currency) IN ('XAF') THEN 'XAF'
            ELSE upper(currency)
        END AS currency,
        TRY_CAST(
            regexp_replace(CAST(principal AS VARCHAR), '[^0-9.\-]', '', 'g')
            AS DOUBLE
        ) AS principal_local,
        TRY_CAST(disbursed_at AS TIMESTAMP) AS disbursed_at,
        TRY_CAST(term_months AS INTEGER) AS term_months,
        TRY_CAST(interest_rate_pct AS DOUBLE) AS interest_rate_pct,
        status,
        TRY_CAST(cbs_fx_rate AS DOUBLE) AS cbs_fx_rate,
        TRY_CAST(principal_usd_cbs AS DOUBLE) AS principal_usd_cbs,
        loan_officer,
        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY try_cast(disbursed_at AS TIMESTAMP) DESC NULLS LAST
        ) AS rn
    FROM "ingestion"."main_raw"."raw_cbs_loans"
),
loans_dedup AS (
    SELECT * EXCLUDE (rn)
    FROM loans
    WHERE rn = 1
),


fx AS (
    SELECT
        currency,
        rate_date,
        TRY_CAST(units_per_usd AS DOUBLE) AS units_per_usd,
        ROW_NUMBER() OVER (
            PARTITION BY currency, rate_date
            ORDER BY try_cast(published_at AS TIMESTAMP) DESC
        ) AS rn
    FROM "ingestion"."main_raw"."raw_fx_rates"
    WHERE lower(rate_type) = 'official'
),
fx_clean AS (
    SELECT currency, rate_date, units_per_usd
    FROM fx
    WHERE rn = 1
),

loans_with_fx AS (
    SELECT
        l.*,
        
        CASE
            WHEN l.cbs_fx_rate IS NOT NULL AND l.cbs_fx_rate > 0
                THEN CASE
                         WHEN l.cbs_fx_rate >= 1 THEN l.cbs_fx_rate
                         ELSE 1.0 / l.cbs_fx_rate
                     END
            WHEN fx.units_per_usd IS NOT NULL THEN fx.units_per_usd
            ELSE NULL
        END AS fx_rate_used,
        CASE
            WHEN l.cbs_fx_rate IS NOT NULL AND l.cbs_fx_rate > 0
                THEN 'cbs_fx_rate'
            WHEN fx.units_per_usd IS NOT NULL
                THEN 'fx_rates_official_on_or_before'
            ELSE 'no_rate'
        END AS fx_rate_source,
        
        CASE
            WHEN l.cbs_fx_rate IS NULL OR l.cbs_fx_rate <= 0 THEN NULL
            WHEN l.cbs_fx_rate >= 1 THEN 'units_per_usd'
            ELSE 'usd_per_unit'
        END AS cbs_rate_convention
    FROM loans_dedup l
    LEFT JOIN fx_clean fx
      ON l.currency = fx.currency
     AND fx.rate_date = (
         SELECT MAX(f2.rate_date)
         FROM fx_clean f2
         WHERE f2.currency = l.currency
           AND f2.rate_date <= CAST(l.disbursed_at AS DATE)
     )
),


xwalk AS (
    SELECT borrower_id, enterprise_client_id, is_minor_restricted
    FROM (
        SELECT
            borrower_id,
            enterprise_client_id,
            is_minor_restricted,
            ROW_NUMBER() OVER (
                PARTITION BY borrower_id
                ORDER BY CASE link_status
                            WHEN 'auto_matched' THEN 1
                            ELSE 2
                         END
            ) AS rn
        FROM "ingestion"."main_marts"."dim_enterprise_client"
        WHERE borrower_id IS NOT NULL
    )
    WHERE rn = 1
),

final AS (
    SELECT
        l.loan_id,
        
        COALESCE(
            x.enterprise_client_id,
            'ent_' || md5('cbs:' || CAST(l.borrower_id AS VARCHAR))
        ) AS enterprise_client_id,
        COALESCE(x.is_minor_restricted, FALSE) AS is_minor_restricted,
        l.borrower_id,
        l.country,
        l.product,
        l.currency,
        l.disbursed_at,
        l.term_months,
        l.interest_rate_pct,
        l.status,
        l.loan_officer,

        l.principal_local,

        l.fx_rate_used,
        l.fx_rate_source,
        l.cbs_rate_convention,
        CASE
            WHEN l.fx_rate_used IS NOT NULL AND l.fx_rate_used > 0
                THEN ROUND(l.principal_local / l.fx_rate_used, 2)
            ELSE NULL
        END AS principal_usd,

        l.principal_usd_cbs
    FROM loans_with_fx l
    LEFT JOIN xwalk x ON l.borrower_id = x.borrower_id
)

SELECT * FROM final