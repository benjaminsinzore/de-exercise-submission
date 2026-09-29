
    

    create  table
      "ingestion"."main"."dq4_publish_manifest__dbt_tmp"
  
    
    as (
      

WITH recon AS (
    SELECT
        count(*) AS total_rows,
        count(*) FILTER (WHERE row_pass) AS passing_rows,
        count(*) FILTER (WHERE NOT row_pass) AS failing_rows
    FROM "ingestion"."main_marts"."fct_loan_repayment_reconciliation"
),
quarantine AS (
    SELECT
        source,
        sum(record_count) AS quarantined
    FROM "ingestion"."main"."dq2_quarantine_log"
    GROUP BY 1
)
SELECT
    current_timestamp AS published_at,
    (SELECT total_rows FROM recon) AS recon_total_rows,
    (SELECT passing_rows FROM recon) AS recon_passing_rows,
    (SELECT failing_rows FROM recon) AS recon_failing_rows,
    (SELECT count(*) FROM quarantine) AS sources_with_quarantine,
    (SELECT sum(quarantined) FROM quarantine) AS total_quarantined
    );
    
  