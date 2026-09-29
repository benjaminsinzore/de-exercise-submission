# OPERATIONS

## 1. Nightly run

`dbt build --profiles-dir . --target prod` runs nightly at 01:00 EAT via cron
(Airflow if scheduling grows). A retry at 04:00 catches late source files.

Sources land in `source/` by 00:30. The pipeline reads them in place and never
writes to `source/`. All raw models are full rebuilds (`materialized='table'`).
`raw_cbs_repayments` deduplicates on `txn_id` inside the model, so day1/day2
overlap does not duplicate. `dbt run --full-refresh` is available for manual
recovery but is not needed in the nightly path.

Execution order is dbt's DAG: seeds → raw → intermediate → marts → tests.
A failing test stops downstream models.

Outputs: `main_raw`, `main_intermediate`, `main_marts`. Published marts:
`fct_loan`, `donor_lending_summary`, `fct_loan_repayment_reconciliation`,
`dim_enterprise_client`.

Run result posts to `#data-eng-alerts` (Slack). Failures page the on-call
data engineer via PagerDuty.

## 2. Alerts and owners

| Alert | Trigger | Owner | Action |
|---|---|---|---|
| Pipeline failed | `dbt build` exits non-zero | On-call data engineer | Triage; re-run or roll back |
| Contract violation | `cbs_repayments_contract_violations` returns rows | On-call data engineer | Contact source team; open PR against `seeds/cbs_repayments_contract.csv` |
| Freshness miss | Source file older than SLA | Data engineer | Chase source team |
| Reconciliation fail | `fct_loan_repayment_reconciliation.row_pass = false` for > 5% of rows | Data engineer + finance analyst | Follow §4 |
| Donor pack blocked | Any `donor_lending_summary` test fails | Data engineer | Block donor pack; investigate |
| FX gap | Any `fct_loan.fx_rate_source = 'no_rate'` row | Data engineer | Ask treasury for the rate |
| Cost anomaly | Warehouse spend > 2× weekly median | Data platform lead | Investigate query patterns |

## 3. Freshness and reliability targets

| Target | Value |
|---|---|
| Nightly start | 01:00 EAT |
| Pipeline completion | 02:00 EAT |
| Source freshness | ≤ 24 h |
| Mart freshness | ≤ 25 h |
| Success rate | ≥ 99% of runs per month |
| Reconciliation pass rate | ≥ 95% of country-month-currency rows |
| Donor pack availability | 06:00 EAT |
| Recovery time (RTO) | 4 h |
| Data loss tolerance (RPO) | 24 h |
| Detection (MTTD) | Next alert cycle (≤ 3 h) |
| Recovery (MTTR) | ≤ 4 h; documented workaround by 8 h |

Rationale: sources are daily extracts; one nightly cycle plus slack is
sufficient. The pipeline runs in seconds today; targets are set for 30× growth.

## 4. When reconciliation fails

Owner: data engineer; finance analyst reviews.

1. **Confirm.** `dbt test --select fct_loan_repayment_reconciliation`. Record
   failing country, month, currency, control, detail, gap, variance %.
2. **Classify.**
   - *Pipeline bug* — schema drift, currency variants, amount parsing.
     Fix in code, rebuild, re-run.
   - *Source issue* — genuine discrepancy. Do not hide it.
   - *Timing* — month-boundary shift. Document, do not patch.
3. **Quantify.** 0.5%–5% gap: log, review monthly. > 5%: escalate to CBS
   same day.
4. **Escalate.** Send the CBS team: country, month, currency, control, detail,
   gap, %, plus affected `loan_id` / `txn_id` where feasible.
5. **Do not silence.** Never widen the tolerance to make a failure pass.
   Tolerance changes require a PR with justification.
6. **Close out.** After the CBS team confirms cause or provides a corrected
   extract, re-run, confirm the row passes, and add a
   `contracts/CHANGELOG.md` entry if the fix touched a contract.

## 5. When to add a component

| Component | Add when | Do not add when |
|---|---|---|
| Columnar / distributed store | Mart tables exceed 100 GB, or build exceeds 30 min, or > 5 concurrent BI users | DuckDB runs in seconds |
| Streaming ingestion | CBS exposes a change log and donor reporting requires < 15 min latency | Sources are daily CSVs |
| Orchestrator | > 20 models, or > 3 interdependent pipelines, or cron is insufficient | `dbt build` on cron covers the schedule |
| Data-quality framework | Tests span pipelines and need a shared library | dbt tests cover the invariants |
| Semantic layer | > 3 BI tools consume the same metrics and disagree | Marts are consumed directly |
| CDC on CBS | CBS exposes a change log and daily extracts lag | CBS is batch-only |
| Object storage for raw | Raw CSVs exceed 10 GB or need retention beyond the repo | Files are small and short-lived |

The current design is minimal on purpose. Each entry has a measurable trigger.
Nothing is added because it "seems more scalable."

## Access and backfills

Credentials come from the deployment environment; no secrets in the repo.
Backfills run `dbt run --select <model>+ --full-refresh` against a dated
snapshot of `source/`; the run posts to the same Slack channel with a
`backfill:` prefix.