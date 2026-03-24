# Phase 8 to 9 Implementation (Detailed)

## 1. Phase 8: Historical tracking with dbt snapshots

## 1.1 Goal
Capture and compare planning changes over time.

## 1.2 Why this phase matters
Planning risk is temporal. A single snapshot cannot reveal slippage dynamics.

## 1.3 What was implemented
Snapshot:
- dbt/snapshots/snp_planning_history.sql

Slippage models:
- dbt/models/intermediate/int_planning_slippage.sql
- dbt/models/marts/kpi_planning_slippage.sql
- dbt/models/marts/kpi_planning_slippage_summary.sql
- tests: dbt/models/marts/kpi_planning_slippage.yml

Interpretation note:
- docs/phase8_temporal_risk_explanation.md

Tracked candidate fields:
- handover period and derived years
- total cost
- planned capacity
- track structure
- project status
- scope proxy (baumassnahme)

## 1.4 Commands used
Initial and repeated run order:

  source .venv/bin/activate
  cd dbt
  dbt build --select staging intermediate
  dbt snapshot --select snp_planning_history
  dbt build --select int_planning_slippage kpi_planning_slippage kpi_planning_slippage_summary

## 1.5 Errors and fixes
Issue: snapshot false-positive change flags.
- Cause: snapshot unique key collisions across multiple rows representing different project slices.
- Fix: improved key by including additional disambiguating field (beschreibung) and expanded tracked change columns.

Issue: dbt snapshot --full-refresh unsupported in environment version.
- Fix: manual reset path used when needed: drop snapshot table then rerun dbt snapshot.

Issue: baseline run still showed one changed row.
- Investigation: source contains same project identity with different cost values in same baseline extract.
- Outcome: model reflects source reality; not a parser bug.

## 1.6 Minor but important details
- Snapshot table must remain cumulative for true history; routine table drops are not operationally correct.
- Summary model provides district-month change and delay rates for stakeholder communication.

---

## 2. Phase 9: Airflow orchestration

## 2.1 Goal
Automate pipeline execution end to end with controllable operational modes.

## 2.2 Why this phase matters
Manual runs are error-prone and hard to reproduce in demonstration/stakeholder contexts.

## 2.3 What was implemented
DAG:
- airflow/dags/berlin_education_pipeline.py

Pipeline modes:
- simple mode (Phase 9.1): ingest -> dbt run -> dbt test
- full mode (Phase 9.2): ingest -> staging -> date parse check -> intermediate -> snapshot -> marts -> tests

Failure behavior (Phase 9.3):
- missing source/executable precheck fails fast
- explicit failure classification for ingestion, dbt tests, date parse checks
- retry and timeout defaults configured

Scheduling logic (Phase 9.4):
- manual by default
- optional scheduled cadence via AIRFLOW_PIPELINE_SCHEDULE
- runtime pipeline mode via DAG run conf pipeline_mode

## 2.4 Commands used (smoke checks)
Use Airflow environment for Airflow CLI:

  source .airflow-venv/bin/activate
  export AIRFLOW_HOME=/workspaces/berlin-educational-sovereignty-spatial-equity-optimizer-/airflow
  airflow dags list
  airflow dags list-import-errors

Programmatic parse check:

  python - <<'PY'
  from airflow.models.dagbag import DagBag
  bag = DagBag(dag_folder='/workspaces/berlin-educational-sovereignty-spatial-equity-optimizer-/airflow/dags', include_examples=False)
  print(bag.dags.keys())
  print(bag.import_errors)
  PY

## 2.5 Errors and fixes
Issue: DAG file hidden from git.
- Cause: .gitignore ignored entire airflow folder.
- Fix: narrowed ignore rules to runtime artifacts and kept dags source trackable.

Issue: Python syntax error in DAG.
- Cause: nested triple-quoted SQL inside bash heredoc string.
- Fix: rewrote SQL strings as concatenated one-line literals.

Issue: Airflow deprecation warnings on old imports.
- Fix: migrated imports to airflow.providers.standard and airflow.sdk paths.

Issue: temporary NameError after import migration.
- Cause: PythonOperator import dropped accidentally.
- Fix: restored PythonOperator from modern provider path.

## 2.6 Minor but important details
- Airflow venv is required for Airflow CLI/scheduler/webserver.
- .venv is used by DAG tasks for dbt and ingestion executables.
- Graphviz warning from airflow CLI is non-blocking for DAG execution.

---

## 3. Cross-phase operational notes often overlooked

- Keep raw companion fields whenever deriving cleaned fields.
- Separate runtime environment concerns from execution binary paths.
- Validate after each major patch, not only at the end.
- Document thresholds/formulas in docs, not only SQL.
- Keep snapshot lifecycle additive except controlled resets.
- Ensure git ignore rules do not hide source code (only runtime artifacts).
