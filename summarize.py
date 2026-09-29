"""
One-shot summary of the pipeline state.

Reads target/ingestion.duckdb and prints, for each exercise deliverable,
the key numbers and pass/fail status.

Run after `dbt build --profiles-dir .`:

    python summarize.py
"""

import os
import sys

import duckdb

DB_PATH = os.environ.get("DB_PATH", "target/ingestion.duckdb")
A3_EXPECTED_PASS = 24  # last known good; below this is a regression


def hr(title: str) -> None:
    print()
    print()
    print(f"== {title} ==")


def table(rows, headers) -> None:
    if not rows:
        print("    (no rows)")
        return
    widths = [len(h) for h in headers]
    for r in rows:
        for i, cell in enumerate(r):
            widths[i] = max(widths[i], len(str(cell)))
    fmt = "    " + " | ".join(f"{{:<{w}}}" for w in widths)
    print(fmt.format(*headers))
    print("    " + "-+-".join("-" * w for w in widths))
    for r in rows:
        print(fmt.format(*[str(c) for c in r]))


def scalar(con, sql: str):
    row = con.execute(sql).fetchone()
    return row[0] if row else None


def safe_scalar(con, sql: str, default=None):
    try:
        return scalar(con, sql)
    except Exception:
        return default


def has_table(con, schema: str, name: str) -> bool:
    try:
        row = con.execute(f"""
            select count(*) from information_schema.tables
            where table_schema = '{schema}' and table_name = '{name}'
        """).fetchone()
        return row[0] > 0
    except Exception:
        return False


def main() -> int:
    if not os.path.exists(DB_PATH):
        print(f"Database not found: {DB_PATH}")
        return 2

    con = duckdb.connect(DB_PATH, read_only=True)

    #Pipeline
    hr("Pipeline")
    models = scalar(con, """
        select count(*) from information_schema.tables
        where table_schema in ('main_raw','main_intermediate','main_marts','main')
    """)
    print(f"    tables in duckdb (all schemas): {models}")
    print(f"    database: {DB_PATH}")

    #A2
    hr("A2 - client identity crosswalk")
    rows = con.execute("""
        select link_status, count(*) as n
        from main_marts.dim_enterprise_client
        group by 1 order by 2 desc
    """).fetchall()
    table(rows, ["link_status", "clients"])

    review = con.execute("""
        select review_reason, count(*) as n
        from main_intermediate.int_client_identity_review
        group by 1 order by 2 desc
    """).fetchall()
    print("    review queue:")
    table(review, ["review_reason", "cases"])

    conflicts = safe_scalar(
        con,
        "select count(*) from main.dq3_identity_conflicts where severity = 'high'",
    )
    print(f"    high-severity identity conflicts: {conflicts}")

    #A3
    hr("A3 - loan/repayment reconciliation")
    rows = con.execute("""
        select
            count(*) as rows,
            count(*) filter (where row_pass) as passing,
            count(*) filter (where not row_pass) as failing,
            count(*) filter (where coverage <> 'present') as coverage_issues
        from main_marts.fct_loan_repayment_reconciliation
    """).fetchone()
    total, passing, failing, coverage_issues = rows
    print(f"    rows: {total}")
    print(f"    passing: {passing}")
    print(f"    failing: {failing}")
    print(f"    coverage issues: {coverage_issues}")
    if passing < A3_EXPECTED_PASS:
        print(f"    REGRESSION: passing dropped below {A3_EXPECTED_PASS}")

    failing_rows = con.execute("""
        select country,
               cast(month as varchar) as month,
               currency,
               ctrl_repay_count, det_repay_count,
               ctrl_repay_amount, det_repay_amount,
               coverage
        from main_marts.fct_loan_repayment_reconciliation
        where not row_pass or coverage <> 'present'
        order by country, month, currency
    """).fetchall()
    if failing_rows:
        print("    failing rows:")
        table(
            failing_rows,
            ["country", "month", "currency",
             "ctrl_ct", "det_ct", "ctrl_amt", "det_amt", "coverage"],
        )

    #B1
    hr("B1 - fct_loan")
    row = con.execute("""
        select
            count(*) as loans,
            count(*) filter (where is_minor_restricted) as restricted,
            count(*) filter (where fx_rate_source = 'cbs_fx_rate') as cbs_rate,
            count(*) filter (where fx_rate_source = 'fx_rates_official_on_or_before') as fallback_rate,
            count(*) filter (where fx_rate_source = 'no_rate') as no_rate,
            count(*) filter (where principal_usd is null) as missing_usd
        from main_marts.fct_loan
    """).fetchone()
    print(f"    loans: {row[0]}")
    print(f"    restricted (minor): {row[1]}")
    print(f"    fx rate from cbs_fx_rate: {row[2]}")
    print(f"    fx rate from fx_rates official: {row[3]}")
    print(f"    fx rate missing: {row[4]}")
    print(f"    principal_usd missing: {row[5]}")

    #B2
    hr("B2 - donor_lending_summary")
    rows = con.execute("""
        select
            count(*) as rows,
            count(*) filter (where is_suppressed) as suppressed,
            count(distinct country) as countries,
            count(distinct month) as months,
            round(sum(coalesce(loans_disbursed_amount_usd, 0)), 2) as total_usd
        from main_marts.donor_lending_summary
    """).fetchone()
    print(f"    rows: {rows[0]}")
    print(f"    suppressed: {rows[1]}")
    print(f"    countries: {rows[2]}")
    print(f"    months: {rows[3]}")
    print(f"    total USD disbursed (visible): {rows[4]}")

    #DQ1
    hr("DQ1 - arrival check")
    unclassified = safe_scalar(con, "select count(*) from main.dq1_arrival_check")
    print(f"    unclassified columns: {unclassified}")
    row_counts = con.execute("""
        select source_file, row_count
        from main.dq1_arrival_row_counts
        order by 1
    """).fetchall()
    table(row_counts, ["source_file", "row_count"])

    #DQ2
    hr("DQ2 - quarantine")
    rows = con.execute("""
        select source, raw_count, clean_count, quarantined_count, balance_delta
        from main.dq2_row_balance
        order by source
    """).fetchall()
    table(rows, ["source", "raw", "clean", "quarantined", "delta"])

    reasons = con.execute("""
        select source, quarantine_reason, record_count
        from main.dq2_quarantine_log
        order by 2 desc, 1
    """).fetchall()
    print("    quarantine reasons:")
    table(reasons, ["source", "reason", "count"])

    #DQ3
    hr("DQ3 - identity metrics")
    if has_table(con, "main", "dq3_identity_metrics"):
        rows = con.execute("select * from main.dq3_identity_metrics").fetchall()
        cols = [d[0] for d in con.description]
        if rows:
            for c, v in zip(cols, rows[0]):
                print(f"    {c}: {v}")
        else:
            print("    (empty)")
    else:
        print("    table not found")

    #DQ4
    hr("DQ4 - publish manifest")
    if has_table(con, "main", "dq4_publish_manifest"):
        cols_rows = con.execute("""
            select column_name from information_schema.columns
            where table_schema = 'main' and table_name = 'dq4_publish_manifest'
            order by ordinal_position
        """).fetchall()
        col_names = [r[0] for r in cols_rows]
        order_col = None
        for candidate in ("evaluated_at", "published_at"):
            if candidate in col_names:
                order_col = candidate
                break
        sql = "select * from main.dq4_publish_manifest"
        if order_col:
            sql += f" order by {order_col} desc"
        sql += " limit 1"
        rows = con.execute(sql).fetchall()
        if rows:
            for c, v in zip(col_names, rows[0]):
                print(f"    {c}: {v}")
        else:
            print("    (empty)")
    else:
        print("    table not found")

    #C1
    hr("C1 - source contract")
    versions = safe_scalar(con, """
        select list(distinct contract_version order by contract_version)
        from main.cbs_repayments_contract
    """)
    print(f"    contract version(s): {versions}")

    violations = None
    for schema in ("main_raw", "main"):
        if has_table(con, schema, "raw_cbs_repayments_contract_check"):
            violations = safe_scalar(
                con,
                f"select count(*) from {schema}.raw_cbs_repayments_contract_check",
            )
            break
    print(f"    contract violations: {violations}")

    con.close()

    print()
    print("For the full pass/fail of every dbt test:")
    print("    dbt test --profiles-dir .")
    return 0


if __name__ == "__main__":
    sys.exit(main())