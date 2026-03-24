# Berlin Educational Sovereignty and Spatial Equity Optimizer

This repository contains an end-to-end analytics engineering system for Berlin education planning. It integrates student demand and school construction planning into a reproducible pipeline that produces district-level KPIs and stakeholder dashboards.

## What This Project Does

The system answers five practical planning questions:
- Where is student demand outpacing planned capacity?
- Which projects are likely to deliver too late to reduce pressure?
- Where does special-needs provision remain under-covered?
- Which districts depend heavily on temporary sites?
- How reliable are the underlying data and transformations?

The pipeline produces validated KPI marts used by Metabase dashboard pages for executive and district-level decisions.

## Why It Matters

Public-sector planners need one coherent view of demand, supply, timing, risk, cost, and data quality. When these dimensions are fragmented, decisions can be delayed or misaligned. This project makes trade-offs explicit by combining:
- equity impact (district and school-type gaps)
- delivery risk (handover timing and slippage)
- inclusion obligations (special-needs coverage)
- financial exposure (high-cost delayed projects and interim dependency)
- confidence context (data trust and completeness)

## Stack and How Each Part Is Used

- DuckDB: local analytical warehouse for raw, staging, intermediate, marts, and snapshots.
- dbt: model orchestration, transformations, tests, and historical snapshotting.
- Python: ingestion and QA automation scripts.
- Airflow: scheduled and on-demand orchestration of ingestion plus dbt workflows.
- Metabase: decision-facing dashboard layer over KPI marts.

## Repository Overview

- src/: ingestion and validation scripts.
- dbt/: source declarations, transformations, tests, and snapshots.
- airflow/: orchestration DAG and runtime config.
- docs/: methodology, data model conventions, and dashboard blueprint.
- reports/: generated QA and ingestion reports.

## Reproduce the Pipeline

### 1. Environment

From repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Place Raw Files

Put both input workbooks in data/raw/:
- od-eckdaten-allg-2024.xlsx
- schulbaukarte-2025-.xlsx

### 3. Ingest Raw Data

```bash
python src/ingest_raw_duckdb.py \
  --db-path data/warehouse/berlin_education.duckdb \
  --output-dir reports
```

### 4. Build Transformations and Tests

```bash
cd dbt
dbt build
```

### 5. Run Historical Snapshot Logic (Optional but Recommended)

```bash
dbt snapshot --select snp_planning_history
dbt build --select int_planning_slippage kpi_planning_slippage kpi_planning_slippage_summary
cd ..
```

### 6. Run Phase 11 QA Validation

```bash
python src/validate_analytics_system.py \
  --db-path data/warehouse/berlin_education.duckdb \
  --output-json reports/phase11_validation_report.json
```

Expected result:
- overall_status = pass
- all four QA batches pass (metric correctness, model consistency, dashboard integrity, edge cases)

## Run the Pipeline with Airflow

Use the Phase 9 DAG in airflow/dags/berlin_education_pipeline.py.

Typical local flow:
```bash
source .airflow-venv/bin/activate
airflow db migrate
airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com
airflow scheduler
```

In another terminal:
```bash
source .airflow-venv/bin/activate
airflow webserver
```

Then trigger DAG berlin_education_pipeline in UI (or CLI) with mode simple or full.

## View the Dashboard in Metabase

1. Start Metabase and connect to DuckDB file data/warehouse/berlin_education.duckdb.
2. Sync metadata.
3. Build questions from analytics_marts tables.
4. Follow dashboard design in docs/phase10_metabase_dashboard_blueprint.md.

Core dashboard datasets:
- analytics_marts.kpi_executive_overview
- analytics_marts.kpi_district_comparison
- analytics_marts.kpi_delivery_timeline
- analytics_marts.kpi_inclusion_coverage
- analytics_marts.kpi_delay_risk_dashboard
- analytics_marts.kpi_zugigkeit_scatter
- analytics_marts.kpi_data_quality_dashboard
- analytics_marts.kpi_data_trust_score

## Key Artifacts for Reviewers

- Technical methodology: docs/methodology.md
- Project framing: docs/project_brief.md
- Dashboard specification: docs/phase10_metabase_dashboard_blueprint.md
- QA evidence: reports/phase11_validation_report.json

## Current Status

Phases 4 through 11 are implemented and validated. Phase 12 documentation and defense preparation package is included under docs/.