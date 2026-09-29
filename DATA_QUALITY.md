# Data quality log

Last updated: 2026-09-29

Every issue found during pipeline development. One row per issue.
Handling categories: corrected, quarantined, flagged, accepted.

| # | Issue | Source file | Column(s) | Records affected | Handling | Fix owner |
|---|---|---|---|---|---|---|
| 1 | IMS stores `sex` as numeric code `1`/`2` in some rows | ims_clients.csv | sex | 38 rows | Corrected: canonicalization in `int_client_identity_prepped.sql` maps `1`→male, `2`→female. | IMS data entry |
| 2 | IMS mixes `F`/`M` and `female`/`male` | ims_clients.csv | sex | ~100 rows | Corrected: canonicalization maps both to `female`/`male`. | IMS data entry |
| 3 | Duplicate `ims_client_id` | ims_clients.csv | ims_client_id | 41 rows | Flagged: sent to `int_client_identity_review`. Kept the most recently updated row in prepped. | IMS data entry |
| 4 | Duplicate `loan_id` | cbs_loans.csv | loan_id | 1 loan | Corrected: deduped in `raw_cbs_loans.sql` by latest `disbursed_at`. | CBS team |
| 5 | NULL `amount_paid` in day2 extract | cbs_repayments_day2.csv | amount_paid | 1 txn | Quarantined: dropped from raw, logged in `quarantine_cbs_repayments`. | CBS team |
| 6 | Reversal not netted into original | cbs_repayments_day2.csv | amount_paid, reversal_of | 1 txn | Corrected: `amount_net` folds reversal into the original `txn_id`. | Data platform |
| 7 | Multiple `rate_type` values in FX source | fx_rates.csv | rate_type | 176 rows | Accepted with filter: `fct_loan` uses `lower(rate_type) = 'official'` only. | Treasury |
| 8 | One loan has no official FX rate on or before disbursement | fx_rates.csv, cbs_loans.csv | units_per_usd, disbursed_at | 1 loan | Flagged: `fx_rate_source = 'no_rate'`, `principal_usd = NULL`. | Treasury |
| 9 | Day 2 repayment extract has a different column shape from day 1 | cbs_repayments_day1.csv, cbs_repayments_day2.csv | amount, amount_paid, agent_code | Whole source | Accepted with contract: declared in `seeds/cbs_repayments_contract.csv`. | CBS team |
| 10 | Country spellings inconsistent | ims_clients.csv | country | ~127 rows | Corrected: normalized in prepped and `fct_loan`. | IMS data entry |
| 11 | 11 reconciliation rows fail due to month-boundary shifts | cbs_control_totals.csv, repayment extracts | paid_at, month | 11 rows | Accepted: documented timing difference, not patched. | CBS team, Data platform |
| 12 | Contract seed had only 1 row and types did not match DuckDB inference | seeds/cbs_repayments_contract.csv | whole file | N/A | Corrected: seed restored to 15 rows, types aligned. | Data platform |
| 13 | 178 identity conflicts from non-canonical gender values | ims_clients.csv, cbs_borrowers.csv | sex, gender | 178 pairs | Corrected: canonicalization in prepped. | Data platform |
| 14 | 1 identity conflict from numeric IMS gender code `1` | ims_clients.csv | sex | 1 pair | Corrected: numeric codes mapped in prepped. | IMS data entry |
| 15 | 70 NULL `is_minor_restricted` in `dim_enterprise_client` | ims_clients.csv, cbs_borrowers.csv | date_of_birth | 70 enterprise clients | Corrected: fail-closed rule applied. 69 IMS-only clients with missing DOB now classified restricted. | Data platform |

## Escalation

Source-team issues are sent with affected IDs. Data-platform issues are in the pipeline backlog. 