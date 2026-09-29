"""
One command that builds and summarizes the pipeline.

From a clean clone:

    python run.py

Runs:

    dbt seed --profiles-dir .        (ensures contract + classification seeds exist)
    dbt build --profiles-dir .       (raw -> staging -> intermediate -> marts + tests)
    summarize.py's report            (pipeline state)

Environment variables:

    DB_PATH          default target/ingestion.duckdb
    DBT_PROFILES_DIR default .
    DBT_TARGET       default dev

Exit codes:

    0  dbt build succeeded and summary printed
    1  dbt build failed (summary still printed if the database exists)
    2  dbt executable not found or missing prerequisite
"""

import os
import subprocess
import sys


def run(cmd: list[str], env: dict[str, str]) -> int:
    print(f"$ {' '.join(cmd)}", flush=True)
    result = subprocess.run(cmd, env=env)
    return result.returncode


def main() -> int:
    profiles_dir = os.environ.get("DBT_PROFILES_DIR", ".")
    target = os.environ.get("DBT_TARGET", "dev")

    env = os.environ.copy()
    env["DBT_PROFILES_DIR"] = profiles_dir

    # 1. Ensure dbt is importable/available.
    try:
        subprocess.run(["dbt", "--version"], check=True, env=env,
                       stdout=subprocess.DEVNULL)
    except FileNotFoundError:
        print("dbt executable not found on PATH.", file=sys.stderr)
        print("Activate your virtual environment first, then retry.", file=sys.stderr)
        return 2
    except subprocess.CalledProcessError as e:
        print(f"dbt --version failed: {e}", file=sys.stderr)
        return 2

    # 2. Seeds first. Idempotent; safe to run every time.
    rc = run(
        ["dbt", "seed", "--profiles-dir", profiles_dir, "--target", target],
        env,
    )
    if rc != 0:
        print("dbt seed failed. Stopping.", file=sys.stderr)
        return 1

    # 3. Full build: models, then tests, in dependency order.
    rc = run(
        ["dbt", "build", "--profiles-dir", profiles_dir, "--target", target],
        env,
    )

    # 4. Summary.
    print()
    print("Pipeline summary")
    print("=" * 16)

    try:
        import summarize  
        summarize.main()
    except ImportError:
        print("summarize.py not found next to run.py; skipping summary.")
    except Exception as e:  
        print(f"summarize.py raised: {e}")

    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())