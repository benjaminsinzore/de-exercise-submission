# Data Engineering Exercise

A dbt + DuckDB pipeline that ingests advisory-system and core-banking
extracts, resolves clients to a single enterprise identity, reconciles
loan and repayment totals against CBS control totals, and publishes a
loan mart and a donor-facing lending summary.

The pipeline is read-only against `source/`. It never writes back to any
source system. Every source column is classified in `classification.yaml`,
and records about minors are treated as restricted personal data.




## Setup

### 1. Create and activate a virtual environment

From the project root:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

On Windows (PowerShell):

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

You should see `(.venv)` in your shell prompt. All subsequent commands
assume the virtual environment is active.

### 2. Install the required packages

```bash
pip install -r requirements.txt  # dbt Core with DuckDB

dbt deps
```

##




### 3. Confirm the source files are in place

The pipeline reads from `source/`. Every file below must exist before the
first run:

```
source/ims_clients.csv
source/cbs_borrowers.csv
source/cbs_loans.csv
source/cbs_repayments_day1.csv
source/cbs_repayments_day2.csv
source/fx_rates.csv
source/cbs_control_totals.csv
source/investment_screening.csv
```

Confirm the profiles file points at a writable DuckDB path:

```bash
cat profiles.yml
```

The `dev` target should have something like:

```yaml
dev:
  type: duckdb
  path: target/ingestion.duckdb
  threads: 4
```

### 4. Run the pipeline

```bash
python run.py
```

That single command:

1. Runs `dbt seed --profiles-dir .` to load the two seeds
   (`cbs_repayments_contract`, `column_classification`).
2. Runs `dbt build --profiles-dir .` to materialize all models and execute
   all data tests in dependency order.
3. Runs `summarize.py` and prints the state of every deliverable.

Expected result on a clean database:

```
Done. PASS=127 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=127

Pipeline summary
================

== Pipeline
    tables in duckdb (all schemas): 50
    ...

== A2 - client identity crosswalk
    ...

== A3 - loan/repayment reconciliation
    ...

== B1 - fct_loan
    ...

== B2 - donor_lending_summary
    ...

== DQ1 - arrival check
    ...

== DQ2 - quarantine
    ...

== DQ3 - identity metrics
    ...

== DQ4 - publish manifest
    ...

== C1 - source contract
    contract version(s): [1]
    contract violations: 0
```

`run.py` exits 0 when the build and summary succeed.

To refresh only the publication-critical marts after a successful build:

```bash
dbt run --select tag:publication_critical --profiles-dir .
```

That rebuilds `fct_loan`, `donor_lending_summary`,
`fct_loan_repayment_reconciliation`, and `dim_enterprise_client`.

## What the pipeline does

1. **Raw load (A1).** Reads each source CSV into a raw table. Excluded
   columns (per `classification.yaml`) never enter the raw layer.
2. **Arrival checks (DQ1).** Confirms each source has the expected columns,
   every column is classified, and every file has rows.
3. **Quarantine (DQ2).** Per-record validation at the staging layer. Bad
   records are quarantined with a reason, never deleted. The pipeline
   proves `raw = clean + quarantined` for every source.
4. **Client identity crosswalk (A2).** Matches IMS clients to CBS borrowers
   and assigns one `enterprise_client_id` per real person. Ambiguous cases
   go to a review queue; high-confidence cases are auto-matched only when
   the pairing is 1:1.
5. **Identity metrics and conflicts (DQ3).** Reports matched, unmatched,
   and review-queue counts, and flags linked records that disagree on core
   attributes.
6. **Loan/repayment reconciliation (A3).** Compares loan and repayment
   totals against `cbs_control_totals.csv` by country, month, and currency,
   with a documented tolerance.
7. **Loan mart (B1).** One row per loan with the enterprise client ID,
   country, principal in local currency, and principal in USD. FX rate is
   `cbs_fx_rate` when present, otherwise the most recent official
   `fx_rates` row on or before `disbursed_at`.
8. **Donor lending summary (B2).** Country-month-currency summary for donor
   disclosure. Restricted (minor) records are excluded. Cells with fewer
   than 5 underlying records are suppressed.
9. **Publish gate (DQ4).** Marts are only refreshed when the reconciliation
   and tests pass. If they fail, the previous marts remain in place and
   the reason is recorded in `dq4_publish_manifest`.
10. **Source contract (C1).** The shape of `cbs_repayments_*.csv` is
    declared in `seeds/cbs_repayments_contract.csv`. Any deviation fails
    `cbs_repayments_contract_violations` before the raw layer is loaded.

## Repository layout

```
models/
  raw/           one model per source file, plus the contract check
  staging/       quarantine, clean, and quarantined variants per source
  intermediate/  client identity prepped, candidates, auto matches, review, metrics
  marts/         fct_loan, donor_lending_summary, dim_enterprise_client,
                 fct_loan_repayment_reconciliation
  dq/            DQ1 arrival checks, DQ2 row balance and quarantine log,
                 DQ3 identity metrics and conflicts, DQ4 publish manifest
seeds/           cbs_repayments_contract, column_classification
contracts/       human-readable source contract and changelog
tests/           singular tests for invariants the YAML tests cannot express
source/          input CSVs (read-only)
profiles.yml     dbt profile for DuckDB
dbt_project.yml  dbt project configuration
packages.yml     dbt package dependencies
run.py           one command: seed, build, summarize
summarize.py     reads the DuckDB file and prints a state report
OPERATIONS.md    nightly run, alerts, targets, runbooks
DATA_QUALITY.md  every issue found, with handling and owner
DECISIONS.md     decisions, including the CBS write-back answer
AI_USE.md        how AI assistance was used
```

## Deliverables

| Exercise | Deliverable | Where |
|---|---|---|
| A1 | Raw loads respecting Rule 1, 2, 3 | `models/raw/` |
| A2 | Client identity crosswalk | `models/intermediate/`, `dim_enterprise_client` |
| A3 | Reconciliation to CBS control totals | `int_loan_repayment_reconciliation`, `fct_loan_repayment_reconciliation` |
| B1 | Loan-level mart with FX | `fct_loan` |
| B2 | Donor lending summary | `donor_lending_summary` |
| B3 | Tests that gate B1 and B2 | `tests/`, `_marts.yml` |
| C1 | Source contract for `cbs_repayments_*.csv` | `seeds/cbs_repayments_contract.csv`, `contracts/` |
| C2 | Operations documentation | `OPERATIONS.md` |
| DQ1–DQ4 | Data quality checkpoints | `models/dq/`, `DATA_QUALITY.md` |



The `summarize.py` output is the top-level view. 




