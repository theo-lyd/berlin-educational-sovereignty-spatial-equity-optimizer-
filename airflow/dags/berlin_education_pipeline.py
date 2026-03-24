from __future__ import annotations

import os
from datetime import timedelta
from pathlib import Path

import pendulum
from airflow import DAG
from airflow.exceptions import AirflowFailException
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import BranchPythonOperator, PythonOperator
from airflow.sdk import TaskGroup

PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_INPUT_DIR = PROJECT_ROOT / "data" / "raw"
DB_PATH = PROJECT_ROOT / "data" / "warehouse" / "berlin_education.duckdb"
REPORTS_DIR = PROJECT_ROOT / "reports"

# dbt/duckdb environment (project .venv)
DBT_BIN = PROJECT_ROOT / ".venv" / "bin" / "dbt"
DBT_PYTHON = PROJECT_ROOT / ".venv" / "bin" / "python"

# Scheduling strategy:
# - Default manual development mode: None (no automatic schedule)
# - Optional schedule mode: set AIRFLOW_PIPELINE_SCHEDULE, e.g. "0 6 * * 1"
SCHEDULE = os.getenv("AIRFLOW_PIPELINE_SCHEDULE") or None
DEFAULT_PIPELINE_MODE = os.getenv("AIRFLOW_PIPELINE_MODE", "full")


def _notify_failure(context):
    task_id = context["task_instance"].task_id
    run_id = context["dag_run"].run_id
    reason = "task failure"

    if "check_source_files" in task_id:
        reason = "source file is missing"
    elif "ingest" in task_id:
        reason = "ingestion failed"
    elif "check_date_parse" in task_id:
        reason = "date parse quality check failed"
    elif "dbt_test" in task_id:
        reason = "dbt tests failed"

    raise AirflowFailException(
        f"Pipeline failed ({reason}). task_id={task_id}, run_id={run_id}. "
        "Check task logs, fix the issue, and rerun from failed tasks."
    )


def _check_required_paths():
    missing = []

    expected_files = [
        RAW_INPUT_DIR / "od-eckdaten-allg-2024.xlsx",
        RAW_INPUT_DIR / "schulbaukarte-2025-.xlsx",
        DBT_BIN,
        DBT_PYTHON,
        PROJECT_ROOT / "src" / "ingest_raw_duckdb.py",
    ]

    for path in expected_files:
        if not path.exists():
            missing.append(str(path))

    if missing:
        raise AirflowFailException(
            "Pipeline precheck failed. Missing required files/executables:\n- "
            + "\n- ".join(missing)
        )


def _choose_pipeline_path(**context):
    run_conf = context.get("dag_run").conf or {}
    mode = str(run_conf.get("pipeline_mode", DEFAULT_PIPELINE_MODE)).lower().strip()

    if mode not in {"simple", "full"}:
        raise AirflowFailException(
            f"Unsupported pipeline_mode='{mode}'. Use 'simple' or 'full'."
        )

    return "simple_pipeline.start_simple" if mode == "simple" else "full_pipeline.start_full"


with DAG(
    dag_id="berlin_education_pipeline",
    description="End-to-end orchestration for ingestion, dbt models/tests, and snapshots",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    schedule=SCHEDULE,
    catchup=False,
    max_active_runs=1,
    default_args={
        "owner": "data-platform",
        "depends_on_past": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=2),
        "execution_timeout": timedelta(minutes=45),
        "on_failure_callback": _notify_failure,
    },
    tags=["berlin", "education", "duckdb", "dbt"],
    params={"pipeline_mode": DEFAULT_PIPELINE_MODE},
    doc_md="""
    ### Berlin Education Pipeline

    `pipeline_mode` options:
    - `simple`: Batch 9.1 skeleton (ingest -> dbt run -> dbt test)
    - `full`: Batch 9.2 full staged pipeline (staging -> intermediate -> marts -> snapshot -> tests)

    Scheduling:
    - manual by default (`schedule=None`)
    - set `AIRFLOW_PIPELINE_SCHEDULE` for demonstration cadence
    - trigger manually before stakeholder review when needed
    """,
) as dag:
    start = EmptyOperator(task_id="start")
    end = EmptyOperator(task_id="end")

    check_source_files = PythonOperator(
        task_id="check_source_files",
        python_callable=_check_required_paths,
    )

    choose_pipeline = BranchPythonOperator(
        task_id="choose_pipeline_mode",
        python_callable=_choose_pipeline_path,
    )

    with TaskGroup(group_id="simple_pipeline") as simple_pipeline:
        start_simple = EmptyOperator(task_id="start_simple")

        ingest_raw_simple = BashOperator(
            task_id="ingest_raw_files",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}\"
            \"{DBT_PYTHON}\" src/ingest_raw_duckdb.py \\
              --input-dir data/raw \\
              --db-path data/warehouse/berlin_education.duckdb \\
              --output-dir reports
            """,
        )

        dbt_run_simple = BashOperator(
            task_id="dbt_run_models",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" run --select path:models
            """,
        )

        dbt_test_simple = BashOperator(
            task_id="dbt_test_models",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" test --select path:models
            """,
        )

        start_simple >> ingest_raw_simple >> dbt_run_simple >> dbt_test_simple

    with TaskGroup(group_id="full_pipeline") as full_pipeline:
        start_full = EmptyOperator(task_id="start_full")

        ingest_raw_full = BashOperator(
            task_id="ingest_raw_files",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}\"
            \"{DBT_PYTHON}\" src/ingest_raw_duckdb.py \\
              --input-dir data/raw \\
              --db-path data/warehouse/berlin_education.duckdb \\
              --output-dir reports
            """,
        )

        dbt_run_staging = BashOperator(
            task_id="dbt_run_staging",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" run --select path:models/staging
            """,
        )

        check_date_parse = BashOperator(
            task_id="check_date_parse_quality",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}\"
            \"{DBT_PYTHON}\" - <<'PY'
from pathlib import Path
import duckdb

root = Path("{PROJECT_ROOT}")
con = duckdb.connect(str(root / "data/warehouse/berlin_education.duckdb"), read_only=True)

total = con.execute(
        "select count(*) "
        "from analytics_staging.stg_school_construction_projects "
        "where handover_period_raw is not null "
        "and lower(trim(handover_period_raw)) not in ('k. a.', 'k.a.', 'k a')"
).fetchone()[0]

failed = con.execute(
        "select count(*) "
        "from analytics_staging.stg_school_construction_projects "
        "where handover_period_raw is not null "
        "and lower(trim(handover_period_raw)) not in ('k. a.', 'k.a.', 'k a') "
        "and handover_year_start is null"
).fetchone()[0]

con.close()

if failed > 0:
    raise SystemExit(
        f"Date parse quality check failed: {{failed}} unparsable handover values out of {{total}} parsable candidates."
    )

print(f"Date parse quality check passed: 0 unparsable values out of {{total}} candidates.")
PY
            """,
        )

        dbt_run_intermediate = BashOperator(
            task_id="dbt_run_intermediate",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" run --select path:models/intermediate
            """,
        )

        dbt_snapshot_refresh = BashOperator(
            task_id="dbt_snapshot_refresh",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" snapshot --select snp_planning_history
            """,
        )

        dbt_run_marts = BashOperator(
            task_id="dbt_run_marts",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" run --select path:models/marts
            """,
        )

        dbt_test_full = BashOperator(
            task_id="dbt_test_full_pipeline",
            bash_command=f"""
            set -euo pipefail
            cd \"{PROJECT_ROOT}/dbt\"
            \"{DBT_BIN}\" test --select path:models path:snapshots
            """,
        )

        (
            start_full
            >> ingest_raw_full
            >> dbt_run_staging
            >> check_date_parse
            >> dbt_run_intermediate
            >> dbt_snapshot_refresh
            >> dbt_run_marts
            >> dbt_test_full
        )

    start >> check_source_files >> choose_pipeline
    choose_pipeline >> simple_pipeline >> end
    choose_pipeline >> full_pipeline >> end
