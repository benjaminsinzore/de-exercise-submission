# cbs_repayments source contract


## What this contract covers

The core banking system publishes repayment extracts as two CSVs per day:

- `cbs_repayments_day1.csv` — the intraday extract
- `cbs_repayments_day2.csv` — the end-of-day correction extract

Day2 may add columns but must not rename or drop any column present in
day1 unless the change is declared in this contract.

## Current version

**v1** — effective 2026-09-29

## Declared columns

### cbs_repayments_day1.csv

| column | type | requirement | canonical name |
|---|---|---|---|
| txn_id | VARCHAR | required | txn_id |
| loan_id | VARCHAR | required | loan_id |
| paid_at | TIMESTAMP | required | paid_at |
| amount | DOUBLE | required | amount_paid |
| currency | VARCHAR | required | currency |
| channel | VARCHAR | required | channel |
| reversal_of | VARCHAR | required | reversal_of |

### cbs_repayments_day2.csv

| column | type | requirement | canonical name |
|---|---|---|---|
| txn_id | VARCHAR | required | txn_id |
| loan_id | VARCHAR | required | loan_id |
| paid_at | TIMESTAMP | required | paid_at |
| amount_paid | DOUBLE | required | amount_paid |
| currency | VARCHAR | required | currency |
| channel | VARCHAR | required | channel |
| agent_code | VARCHAR | required | agent_code |
| reversal_of | VARCHAR | required | reversal_of |

## Rename map

| day1 column | day2 column | canonical name |
|---|---|---|
| amount | amount_paid | amount_paid |

The loader treats day1.amount and day2.amount_paid as the same field.

## How this contract is enforced

1. `seeds/cbs_repayments_contract.csv` is the machine-readable form of
   this document. Both must agree.
2. `models/raw/raw_cbs_repayments_contract_check.sql` reads the actual
   header of each CSV using DuckDB's `DESCRIBE` and compares it to the
   seed.
3. `tests/cbs_repayments_contract_violations.sql` fails the dbt run if
   any column is missing, extra, or renamed without a mapping in the seed.
4. `models/raw/raw_cbs_repayments.sql` reads each file with an explicit
   column list and no `union_by_name`, so a header change causes a
   compile-time failure, not a silent NULL.

## Change process

1. The contract test fails on the next `dbt run`.
2. An engineer inspects the failure, sees which column was added, removed,
   or renamed.
3. The engineer updates this file, the seed, and — if needed — the raw
   model in a single PR.
4. The PR must include a changelog entry below.
5. Reviewers approve only if the change is intentional and justified.

## Changelog

### v1 — 2026-09-29
- Initial contract.
- day1 has `amount`; day2 has `amount_paid` and `agent_code`.
- Rename map declared: `amount` ≡ `amount_paid`.
- Reviewer: platform team.