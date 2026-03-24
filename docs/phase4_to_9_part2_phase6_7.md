# Phase 6 to 7 Implementation (Detailed)

## 1. Phase 6: Standardization and business rules

## 1.1 Goal
Convert raw fields to clean analytical fields while preserving auditability.

## 1.2 Why this phase matters
Cross-dataset comparisons require controlled dimensions and parse-safe numeric/time fields.

## 1.3 What was implemented
Reusable macros:
- dbt/macros/normalization.sql

Key macro functions:
- null_if_unknown
- parse_numeric_text
- parse_eur_amount
- parse_year_start
- parse_year_end
- canonical_bezirk
- canonical_schulart
- is_special_needs
- is_temporary_site

Staging model upgrades:
- dbt/models/staging/stg_school_construction_projects.sql
- dbt/models/staging/stg_student_demand.sql

Added fields include:
- bezirk_raw, bezirk_clean
- schulart_raw, schulart_clean
- planned_capacity_raw, planned_capacity
- total_cost_raw, total_cost_eur
- handover_period_raw, handover_year_start, handover_year_end
- is_special_needs, is_temporary_site

Tests updated:
- dbt/models/staging/stg_school_construction_projects.yml
- dbt/models/staging/stg_student_demand.yml

## 1.4 Commands used

  source .venv/bin/activate
  cd dbt
  dbt build --select staging

## 1.5 Errors and fixes
Issue: accepted_values test syntax deprecation.
- Fix: migrated tests to arguments syntax.

Issue: mapping quality risk from unknown source values.
- Fix: profiled real source distributions before finalizing canonical rules.

## 1.6 Minor but important details
- Drehscheibe intentionally treated as temporary-site signal, not canonical school type.
- k. A. markers are converted to null in cleaned fields but preserved in raw companions.
- Numeric parsing supports Mio and Tsd multipliers and comma decimals.

---

## 2. Phase 7: Intermediate models and KPI layer

## 2.1 Goal
Generate decision-ready metrics from standardized staging data.

## 2.2 Why this phase matters
Stakeholder decisions require aggregation, comparison, timing, risk, and trust metrics, not raw rows.

## 2.3 What was implemented
Intermediate models:
- dbt/models/intermediate/int_district_aggregation.sql
- dbt/models/intermediate/int_school_type_mismatch.sql
- dbt/models/intermediate/int_delivery_timeline.sql
- dbt/models/intermediate/int_inclusion_coverage.sql
- dbt/models/intermediate/int_project_risk_ranking.sql
- dbt/models/intermediate/int_data_trust_score.sql

KPI mart models:
- dbt/models/marts/kpi_district_summary.sql
- dbt/models/marts/kpi_school_type_mismatch.sql
- dbt/models/marts/kpi_delivery_timeline.sql
- dbt/models/marts/kpi_inclusion_coverage.sql
- dbt/models/marts/kpi_project_risk_ranking.sql
- dbt/models/marts/kpi_data_trust_score.sql
- tests: dbt/models/marts/kpi_layer.yml

## 2.4 Commands used

  source .venv/bin/activate
  cd dbt
  dbt build --select path:models/intermediate path:models/marts

## 2.5 Errors and fixes
Issue: dbt selection criterion intermediate,marts matched nothing.
- Cause: selector format was invalid for this context.
- Fix: used explicit path selectors.

Issue: risk and trust assumptions were implicit in SQL only.
- Fix: documented thresholds and formulas in methodology and appendix mapping files.

## 2.6 Minor but important details
- Risk score normalized from total component score to 0-100.
- Demand pressure score based on district ratio bands.
- Data trust includes both missingness and unknown marker penalties.
- Overall trust row added in addition to per-model rows.
