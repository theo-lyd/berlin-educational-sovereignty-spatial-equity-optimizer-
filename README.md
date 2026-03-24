# Berlin Educational Sovereignty & Spatial Equity Optimizer

A public-sector analytics engineering capstone project that aligns student demand with school infrastructure planning across Berlin’s districts. The project integrates demand-side education data with supply-side school construction data to analyze capacity gaps, delayed delivery risk, spatial inequity, inclusion coverage, and financial exposure.

## Problem
Berlin’s education planning requires timely, district-level visibility into where school capacity is insufficient, where construction delays create risk, and whether inclusive education obligations are being met. This project addresses that need through an end-to-end analytical system.

## Objectives
- Measure demand-supply gaps by district and school type
- Track project delivery timing and planning slippage
- Evaluate special-needs inclusion coverage
- Identify temporary-site dependency and financial risk
- Provide a dashboard for public-sector decision support

## Tech Stack
- **DuckDB** for analytical storage and local SQL execution
- **dbt** for transformations, tests, snapshots, and modular modeling
- **Python** for data ingestion, enrichment, and analysis
- **Airflow** for orchestration and pipeline scheduling
- **Metabase** for dashboarding and stakeholder reporting
- **GitHub Codespaces** as the development environment

## Data Sources
- District-level student demand data
- School construction and infrastructure planning data

## Methodology
The project follows a layered analytics architecture:
- Raw ingestion
- Staging and standardization
- Intermediate enrichment
- Mart-layer reporting
- Historical snapshots for planning changes
- Dashboard publication for decision makers

## Key Outputs
- District demand-supply gap analysis
- Capacity delivery timeline
- Inclusion coverage metrics
- Project delay risk ranking
- Data trust score
- Interactive public-sector dashboard

## Public-Sector Relevance
This project is designed for presentation to a Berlin education stakeholder and supports planning decisions related to capacity, inclusion, budget efficiency, and spatial equity.

## Repository Structure
See the `docs/` and `dbt/` folders for project documentation and transformation logic.

## Raw Ingestion (DuckDB)
The script in `src/ingest_raw_duckdb.py` does the following:
- Reads both source Excel workbooks sheet by sheet
- Loads each sheet into DuckDB raw tables without destructive cleaning
- Preserves placeholders such as `k. A.` and German-formatted strings as-is
- Writes a DuckDB ingestion log table (`raw.raw_ingestion_log`)
- Exports a CSV ingestion log
- Generates markdown and JSON validation reports
- Checks loaded row counts against source workbook row counts

Raw tables are created in the `raw` schema with names derived from workbook and sheet names:
- `raw.raw__<workbook_slug>__<sheet_slug>`

### Run
1. Place both Excel files in `data/raw/`:
	 - `od-eckdaten-allg-2024.xlsx`
	 - `schulbaukarte-2025-.xlsx`
2. Activate `.venv` (not `.airflow-venv`).
3. From the project root, run:

```bash
python src/ingest_raw_duckdb.py \
	--db-path data/warehouse/berlin_education.duckdb \
	--output-dir reports
```

## Operational Runbooks

### Phase 8 Repeat Run (Snapshots + Slippage)
Run this sequence whenever planning data is refreshed (for example weekly/monthly):

```bash
source .venv/bin/activate
cd dbt
dbt build --select staging intermediate
dbt snapshot --select snp_planning_history
dbt build --select int_planning_slippage kpi_planning_slippage kpi_planning_slippage_summary
dbt build --select path:models/marts
```

Note: keep snapshot history cumulative. Do not routinely drop snapshot tables during normal runs.

## Status
Capstone thesis in active development.