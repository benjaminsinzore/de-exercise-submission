

WITH scored AS (
    SELECT
        *,
        CASE
            WHEN txn_id IS NULL OR txn_id = '' THEN 'missing_txn_id'
            WHEN loan_id IS NULL THEN 'missing_loan_id'
            WHEN try_cast(paid_at AS TIMESTAMP) IS NULL THEN 'invalid_paid_at'
            WHEN currency IS NULL
                 OR upper(currency) NOT IN ('KES','KSH','ETB','RWF','SSP','XAF','USD','EUR')
                THEN 'invalid_currency'
            WHEN amount_paid IS NULL THEN 'missing_amount_paid'
            WHEN amount_paid < 0 THEN 'negative_amount_paid'
            ELSE NULL
        END AS quarantine_reason
    FROM "ingestion"."main_raw"."raw_cbs_repayments"
)
SELECT * FROM scored