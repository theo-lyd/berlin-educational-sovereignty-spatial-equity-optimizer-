# Thesis Report
## Berlin Educational Sovereignty and Spatial Equity Optimizer

## 1. Executive Summary

This thesis delivers a reproducible analytics engineering system to support Berlin public-sector education planning. The system integrates student demand and school construction planning data into validated KPI marts and decision-oriented dashboard datasets.

The final output supports district-level prioritization across capacity gap, delay exposure, inclusion coverage, financial exposure, and data confidence.

## 2. Problem and Motivation

Berlin planning stakeholders need one coherent view of:
- where demand outpaces planned capacity
- where planned delivery is too late to reduce pressure
- where special-needs provision is under-covered
- where temporary-site dependency increases cost risk

Without a unified pipeline, these questions are answered in fragmented workflows, reducing transparency and slowing action.

## 3. Data Sources

The project uses two primary source workbooks:
- district-level student demand data
- school construction/project planning data

Raw ingestion preserves source fidelity and records ingestion audit metadata.

## 4. System Architecture

Layered architecture:
- raw (source-fidelity ingestion in DuckDB)
- analytics_staging (standardization and parsing)
- analytics_intermediate (domain transformations)
- analytics_marts (dashboard-ready KPI tables)
- analytics_snapshots (historical planning state)

Core tooling:
- DuckDB for analytical storage
- dbt for transformation and testing
- Python for ingestion and QA automation
- Airflow for orchestration
- Metabase for stakeholder dashboards

## 5. Methodology

Method sequence:
1. ingest and validate raw data
2. standardize and parse in staging
3. derive reusable intermediate models
4. publish KPI marts
5. validate correctness and consistency (Phase 11 QA)
6. prepare defense and stakeholder communication package

Validation includes:
- metric correctness checks
- cross-layer consistency checks
- dashboard model/filter integrity checks
- edge-case checks (missing values, zero capacity, special-needs preservation)

## 6. KPI Framework

Demand KPIs:
- total student demand
- special-needs demand
- district demand share

Supply KPIs:
- planned capacity
- capacity additions by year
- zugigkeit after construction
- supply coverage rate

Equity KPIs:
- district gap score
- inclusion coverage rate
- spatial relief score

Risk KPIs:
- delay exposure
- interim-site dependency risk
- planning slippage
- financial exposure

Data quality KPIs:
- data trust score
- completeness rate
- transformation success rate

## 7. Results Snapshot

Validated baseline values:
- total student demand: 404019
- total planned capacity: 71900
- total gap: 332119
- special-needs demand: 9027
- special-needs planned capacity: 1516

Interpretation:
- structural demand-capacity gap is substantial
- inclusion undercoverage is material
- delivery timing and risk prioritization are central for policy action

## 8. Limitations

- source scope is limited to available workbooks
- planning data captures intent, not guaranteed delivery
- district-level grain is coarser than catchment-level analysis
- output is descriptive/risk-oriented, not causal forecasting

## 9. Public-Sector Value

The system improves decision readiness by making trade-offs explicit across demand pressure, delivery timing, inclusion compliance, and financial exposure. It also improves transparency through reproducible logic and explicit data quality signals.

## 10. Reproducibility and Handoff

Reproducibility path:
- README runbook
- dbt models/tests/snapshots
- Phase 11 validation report
- defense documentation package (slides, narrative, Q&A)

Repository publication includes tagged phase milestones and a final release tag for rollback/reference.
