# Phase 4 to 5 Implementation (Detailed)

## 1. Project Setup Decisions (Foundation for all phases)

### 1.1 Why this setup
The project requires two execution contexts:
- analytics transformations and ingestion (DuckDB and dbt)
- orchestration runtime (Airflow)

Keeping them separate prevents dependency conflicts and supports repeatable operations.

### 1.2 Environment model
- .venv: ingestion scripts, DuckDB, dbt runs/tests/snapshots
- .airflow-venv: Airflow CLI, scheduler, webserver, DAG parsing

Important operational detail:
- Airflow tasks were configured to call executables by absolute path inside .venv, so DAG execution does not depend on manual activation of .venv.

### 1.3 Core folder conventions
- Raw input files: data/raw
- DuckDB file: data/warehouse/berlin_education.duckdb
- Ingestion reports: reports
- dbt project root: dbt
- Airflow DAGs: airflow/dags

---

## 2. Phase 4: Raw ingestion into DuckDB

## 2.1 Goal
Build auditable raw ingestion with source fidelity.

## 2.2 Why this phase matters
All downstream analytics quality depends on preserving source truth first. If raw values are destructively cleaned at ingestion, traceability is lost.

## 2.3 What was implemented
- Script: src/ingest_raw_duckdb.py
- Validation script: src/validate_raw_duckdb.py

Ingestion behavior:
- reads both Excel workbooks sheet by sheet
- loads each sheet into raw schema tables in DuckDB
- keeps placeholders such as k. A. and locale-formatted strings as-is
- writes raw.raw_ingestion_log table
- exports reports/raw_ingestion_log.csv
- exports reports/raw_load_validation_report.md
- exports reports/raw_load_validation_report.json
- checks expected row counts from workbook sheets against loaded row counts

Raw naming convention:
- raw.raw__<workbook_slug>__<sheet_slug>

## 2.4 Commands used
From project root:

  source .venv/bin/activate
  python src/ingest_raw_duckdb.py --db-path data/warehouse/berlin_education.duckdb --output-dir reports

Optional verification:

  python src/validate_raw_duckdb.py --db-path data/warehouse/berlin_education.duckdb --report-json reports/raw_load_validation_report.json

## 2.5 Outputs produced
- raw.raw__od_eckdaten_allg_2024__tabelle1
- raw.raw__schulbaukarte_2025__tabelle1
- raw.raw_ingestion_log
- reports/raw_ingestion_log.csv
- reports/raw_load_validation_report.md
- reports/raw_load_validation_report.json

## 2.6 Errors and fixes
Issue: output location mismatch with target operating convention.
- Symptom: default path documented as data/reports/phase4.
- Fix: changed defaults and usage to reports in both ingestion and validation scripts and README instructions.

Issue: IDE showed unresolved imports (duckdb/pandas/openpyxl).
- Symptom: static analysis warning.
- Fix: confirmed runtime through .venv activation and script execution.
- Note: this was interpreter-selection context, not code failure.

## 2.7 Minor but important details
- Process is idempotent at table level (drops/recreates raw sheet table).
- Missing workbook files trigger explicit error and non-zero exit.
- Row expectation derived from worksheet max rows with header adjustment.

---

## 3. Phase 5: dbt skeleton and source wiring (bridge to transformation phases)

## 3.1 Goal
Create reproducible dbt project structure connected to raw DuckDB tables.

## 3.2 Why this phase matters
Without stable source declarations and project scaffolding, later standardization and KPI models are fragile and not testable.

## 3.3 What was implemented
- dbt project scaffold under dbt
- source models under dbt/models/sources
- initial staging models under dbt/models/staging
- schema tests for staging fields

## 3.4 Commands used
From project root:

  source .venv/bin/activate
  cd dbt
  dbt build --select staging

## 3.5 Critical errors and fixes
Issue: Binder Error: Catalog main does not exist.
- Cause: source YAML contained database: main.
- Fix: removed database: main from source YAML for DuckDB file-backed setup.

Issue: stg_student_demand failed with Traeger column error.
- Cause: source column is Traeger with trailing space.
- Fix: changed reference from Traeger to Traeger with trailing space in staging SQL.

Issue: dbt accepted_values deprecation warning.
- Cause: top-level values syntax.
- Fix: moved values under arguments for dbt 1.11 syntax.

## 3.6 Minor but important details
- Staging build was validated after each correction, not only at the end.
- Value profiling was done from real staged data before defining canonical mappings.
- This reduced assumption drift and prevented mapping to non-existent categories.
