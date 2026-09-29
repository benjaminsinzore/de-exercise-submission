

WITH raw_src AS (
    SELECT
        txn_id,
        loan_id,
        try_cast(paid_at AS TIMESTAMP) AS paid_at,
        TRY_CAST(amount AS DOUBLE) AS amount_paid,
        currency,
        channel,
        NULL::VARCHAR AS agent_code,
        reversal_of,
        'cbs_repayments_day1.csv' AS source_file
    FROM read_csv_auto(
        'source/cbs_repayments_day1.csv',
        header = true,
        sample_size = -1
    )

    UNION ALL

    SELECT
        txn_id,
        loan_id,
        try_cast(paid_at AS TIMESTAMP) AS paid_at,
        TRY_CAST(amount_paid AS DOUBLE) AS amount_paid,
        currency,
        channel,
        agent_code,
        reversal_of,
        'cbs_repayments_day2.csv' AS source_file
    FROM read_csv_auto(
        'source/cbs_repayments_day2.csv',
        header = true,
        sample_size = -1
    )
),

filtered AS (
    SELECT *
    FROM raw_src
    WHERE amount_paid IS NOT NULL
),

deduped AS (
    SELECT *
    FROM filtered
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY txn_id
        ORDER BY
            (amount_paid IS NOT NULL) DESC,
            try_cast(paid_at AS TIMESTAMP) DESC NULLS LAST
    ) = 1
),

originals AS (
    SELECT txn_id, paid_at AS original_paid_at
    FROM deduped
),

with_dates AS (
    SELECT
        d.txn_id,
        d.loan_id,
        CASE
            WHEN d.reversal_of IS NOT NULL AND o.original_paid_at IS NOT NULL
                THEN o.original_paid_at
            ELSE d.paid_at
        END AS paid_at,
        d.amount_paid,
        d.currency,
        d.channel,
        d.agent_code,
        d.reversal_of,
        d.source_file
    FROM deduped d
    LEFT JOIN originals o ON d.reversal_of = o.txn_id
),

reversal_amounts AS (
    SELECT
        reversal_of AS original_txn_id,
        SUM(amount_paid) AS total_reversal_amount
    FROM with_dates
    WHERE reversal_of IS NOT NULL
    GROUP BY 1
),

final AS (
    SELECT
        w.txn_id,
        w.loan_id,
        w.paid_at,
        w.amount_paid,
        COALESCE(r.total_reversal_amount, 0) AS reversal_amount,
        w.amount_paid + COALESCE(r.total_reversal_amount, 0) AS amount_net,
        w.currency,
        w.channel,
        w.agent_code,
        w.reversal_of,
        w.source_file
    FROM with_dates w
    LEFT JOIN reversal_amounts r ON w.txn_id = r.original_txn_id
)

SELECT
    txn_id,
    loan_id,
    paid_at,
    amount_paid,
    reversal_amount,
    amount_net,
    currency,
    channel,
    agent_code,
    reversal_of,
    source_file
FROM final
WHERE reversal_of IS NULL