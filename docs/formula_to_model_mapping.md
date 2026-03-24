# Formula-to-Model Mapping (Thesis Appendix Companion)

This page maps each key analytical formula to the dbt model that implements it, so methodology claims can be traced directly to executable code.

## 1. Demand-Supply and Pressure Formulas

### 1.1 District Demand-Supply Gap
- Model: `dbt/models/intermediate/int_district_aggregation.sql`
- Output fields:
  - `demand_supply_gap_total = demand_students_total - planned_capacity_total`
  - `demand_supply_gap_permanent = demand_students_total - planned_capacity_permanent`
  - `demand_pressure_ratio_total = demand_students_total / planned_capacity_total` (null-safe)

### 1.2 School-Type Mismatch
- Model: `dbt/models/intermediate/int_school_type_mismatch.sql`
- Output fields:
  - `demand_supply_gap_total = demand_students_total - planned_capacity_total`
  - `demand_supply_gap_permanent = demand_students_total - planned_capacity_permanent`
  - `demand_pressure_ratio_total = demand_students_total / planned_capacity_total` (null-safe)

## 2. Timeline and Inclusion Formulas

### 2.1 Delivery Timeline (Capacity Over Time)
- Model: `dbt/models/intermediate/int_delivery_timeline.sql`
- Output fields:
  - `planned_capacity_total` by `delivery_year`
  - `cumulative_capacity_total = cumulative sum(planned_capacity_total)`
  - `cumulative_capacity_permanent = cumulative sum(planned_capacity_permanent)`

### 2.2 Inclusion Coverage
- Model: `dbt/models/intermediate/int_inclusion_coverage.sql`
- Output fields:
  - `special_needs_gap_total = special_needs_demand_students - special_needs_planned_capacity`
  - `special_needs_gap_permanent = special_needs_demand_students - special_needs_planned_capacity_permanent`
  - `special_needs_coverage_ratio = special_needs_planned_capacity / special_needs_demand_students` (null-safe)

## 3. Project Risk Formulas

### 3.1 Project Risk Component Scores
- Model: `dbt/models/intermediate/int_project_risk_ranking.sql`
- Components:
  - `score_handover_delay`
  - `score_project_cost`
  - `score_interim_dependency`
  - `score_missing_data`
  - `score_demand_pressure`

### 3.2 Composite Risk Score
- Model: `dbt/models/intermediate/int_project_risk_ranking.sql`
- Output field:
  - `project_risk_score = round((sum_component_scores / 20) * 100, 2)`

### 3.3 Risk Bucket Classification
- Model: `dbt/models/intermediate/int_project_risk_ranking.sql`
- Output field:
  - `project_risk_bucket`
- Thresholds:
  - `high` if total component score >= 14
  - `medium` if total component score >= 8 and < 14
  - `low` otherwise

### 3.4 Risk Ranking
- Model: `dbt/models/intermediate/int_project_risk_ranking.sql`
- Output field:
  - `project_risk_rank = dense_rank(...)`
  - Ordered by total component score desc, then cost desc, then capacity desc

## 4. Data Trust Formulas

### 4.1 Completeness and Missingness
- Model: `dbt/models/intermediate/int_data_trust_score.sql`
- Output fields:
  - `completeness_pct = round((1 - missing_cell_count / assessed_cell_count) * 100, 2)`
  - `missingness_pct = round((missing_cell_count / assessed_cell_count) * 100, 2)`

### 4.2 Data Trust Score
- Model: `dbt/models/intermediate/int_data_trust_score.sql`
- Output field:
  - `data_trust_score = round((1 - (missing_cell_count + unknown_marker_count) / assessed_cell_count) * 100, 2)`

### 4.3 Assessed-Cell Denominators
- Model: `dbt/models/intermediate/int_data_trust_score.sql`
- Definitions:
  - Demand model denominator: `row_count * 4`
  - Construction model denominator: `row_count * 5`

## 5. Historical Tracking and Slippage Formulas

### 5.1 Snapshot Change Detection
- Model: `dbt/snapshots/snp_planning_history.sql`
- Snapshot strategy:
  - `strategy='check'`
  - `check_cols` include handover, cost, capacity, track count, project status, and scope proxy (`baumassnahme`)

### 5.2 Planning Slippage Deltas
- Model: `dbt/models/intermediate/int_planning_slippage.sql`
- Output fields:
  - `handover_year_start_delta`
  - `handover_year_end_delta`
  - `total_cost_delta_eur`
  - `planned_capacity_delta`
  - `track_structure_delta`

### 5.3 Slippage Flags
- Model: `dbt/models/intermediate/int_planning_slippage.sql`
- Output flags:
  - `handover_moved_later`
  - `handover_moved_earlier`
  - `cost_increased`
  - `cost_decreased`
  - `capacity_changed`
  - `track_count_changed`
  - `project_scope_changed`
  - `project_status_changed`
  - `has_planning_change`

### 5.4 Slippage Summary Rates
- Model: `dbt/models/marts/kpi_planning_slippage_summary.sql`
- Output fields:
  - `change_rate = changed_records / records_in_snapshot`
  - `delay_rate = delayed_records / records_in_snapshot`

## 6. KPI Table Materialization Mapping

- `dbt/models/marts/kpi_district_summary.sql` -> `int_district_aggregation`
- `dbt/models/marts/kpi_school_type_mismatch.sql` -> `int_school_type_mismatch`
- `dbt/models/marts/kpi_delivery_timeline.sql` -> `int_delivery_timeline`
- `dbt/models/marts/kpi_inclusion_coverage.sql` -> `int_inclusion_coverage`
- `dbt/models/marts/kpi_project_risk_ranking.sql` -> `int_project_risk_ranking`
- `dbt/models/marts/kpi_data_trust_score.sql` -> `int_data_trust_score`
- `dbt/models/marts/kpi_planning_slippage.sql` -> `int_planning_slippage`
- `dbt/models/marts/kpi_planning_slippage_summary.sql` -> aggregated `int_planning_slippage`

---

Use this page as the traceability index in the thesis appendix: each formula above is tied to a concrete model path and output field name.
