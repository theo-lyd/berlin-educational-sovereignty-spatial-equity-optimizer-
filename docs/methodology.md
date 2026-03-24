# Methodology
## Berlin Educational Sovereignty and Spatial Equity Optimizer

## 1. Methodological Goal

The methodology is designed for two reviewer groups at the same time:
- technical reviewers who require reproducibility, traceability, and validation
- public-sector reviewers who require interpretable and policy-relevant outputs

The guiding sequence is:

Clean raw data -> standardize and model -> validate metrics -> automate pipeline -> publish decision dashboard -> document limits and confidence.

## 2. Data Sources

Primary inputs:
- District-level student demand workbook (education demand)
- School construction planning workbook (capacity, timing, cost, project context)

Source handling principles:
- preserve source fidelity in raw schema
- keep original text columns for auditability
- treat placeholders such as k. A. as unknown rather than fabricated values
- ingest without destructive overwrites

Raw ingestion outputs:
- raw DuckDB tables per workbook/sheet
- ingestion log
- load validation report in reports/

## 3. Transformation Logic

Transformation logic is implemented in dbt and split into three layers.

### 3.1 Staging Layer

Purpose:
- normalize categorical labels
- parse numeric and monetary fields
- parse date windows into year_start and year_end
- keep raw and cleaned fields side by side

Examples:
- district canonicalization
- school type canonicalization
- parse German-style cost expressions into total_cost_eur
- parse handover period into handover_year_start and handover_year_end

### 3.2 Intermediate Layer

Purpose:
- derive analytical structures reusable across KPI marts

Core models:
- district aggregation
- school-type mismatch
- delivery timeline
- inclusion coverage
- project risk ranking
- data trust scoring
- planning slippage from snapshots

### 3.3 Mart Layer

Purpose:
- provide stakeholder-ready KPI tables for Metabase

Core marts:
- executive overview
- district comparison
- delivery timeline
- inclusion coverage
- delay risk dashboard
- zugigkeit scatter
- data quality dashboard
- data trust score

## 4. KPI Definitions

The KPI framework is grouped into five domains.

### 4.1 Demand KPIs
- Total Student Demand
- Special-Needs Demand
- District Demand Share

### 4.2 Supply KPIs
- Planned Capacity
- Capacity Additions by Year
- Zugigkeit After Construction
- Supply Coverage Rate

### 4.3 Equity KPIs
- District Gap Score
- Inclusion Coverage Rate
- Spatial Relief Score

### 4.4 Risk KPIs
- Delay Exposure
- Interim-Site Dependency Risk
- Planning Slippage
- Financial Exposure

### 4.5 Data Quality KPIs
- Data Trust Score
- Completeness Rate
- Transformation Success Rate

Metric construction rules:
- explicit null handling
- divide-by-zero protection
- ratio calculations only on valid denominators
- snapshot-based temporal comparison for slippage

## 5. Modeling Architecture

Architecture pattern:
- raw -> analytics_staging -> analytics_intermediate -> analytics_marts

Operational components:
- dbt build and tests for transformation correctness
- dbt snapshot for historical planning change tracking
- Airflow DAG for orchestration (simple/full modes)
- Python validation script for cross-layer QA

This architecture supports:
- reproducibility (same code, same outputs)
- observability (tests and validation outputs)
- modular maintainability (layered responsibility)

## 6. Validation and Quality Assurance

Validation strategy combines dbt-native tests and custom QA checks.

QA batches:
- metric correctness checks (district, students, projects, capacity, cost parsing)
- cross-model consistency checks (staging/intermediate/marts)
- dashboard integrity checks (model-field-filter coverage)
- edge-case checks (missing dates/costs, unknown districts, special-needs, zero-capacity)

Evidence artifact:
- reports/phase11_validation_report.json

## 7. Dashboard Method

Dashboard design follows a decision-oriented structure:
- executive overview
- district gap comparison
- delivery timeline
- inclusion coverage
- financial and interim risk
- zugigkeit vs demand
- data trust and audit

Design constraints:
- filterable by district, school type, and risk-related dimensions
- each chart must be traceable to one dbt mart model
- KPI cards include confidence context (data trust)

## 8. Public-Sector Interpretation Method

Interpretation is structured around planning actionability:
- where to prioritize capacity investment
- where delivery delay threatens near-term service
- where inclusion obligations are under pressure
- where temporary infrastructure creates financial drag

Each KPI is linked to a planning question and not only a technical metric.

## 9. Limitations

Known methodological limits:
- limited source scope (two primary upstream workbooks)
- planning data reflects intended delivery, not guaranteed delivery
- district-level aggregation is coarser than school-catchment-level analysis
- no causal inference; outputs are descriptive and risk-oriented
- duplicate project identity can occur in source records and is reported explicitly

Implication for reviewers:
- outputs are decision support signals, not deterministic forecasts
- results should be interpreted with scenario review and domain validation

## 10. Reproducibility Checklist

1. Create and activate .venv, install requirements.
2. Ingest raw files into DuckDB.
3. Run dbt build.
4. Run dbt snapshot for temporal history.
5. Run Phase 11 validator and review JSON report.
6. Sync Metabase and validate dashboard values against marts.

This process ensures the thesis can be reproduced and audited end-to-end.