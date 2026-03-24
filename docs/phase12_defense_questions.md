# Phase 12 Likely Defense Questions and Answers

## 1. Why DuckDB?

Answer:
DuckDB is a strong fit for this thesis because it provides analytical SQL performance with minimal infrastructure overhead. It supports local reproducibility in a single file, integrates well with dbt, and is practical for capstone-scale public-sector analytics where deployment simplicity and auditability are important.

## 2. Why dbt?

Answer:
dbt provides modular transformation logic, lineage clarity, and built-in testing. It allows raw-to-KPI logic to remain declarative and version-controlled. For a defense context, dbt also makes assumptions explicit and reviewable model by model.

## 3. How was data quality handled?

Answer:
Data quality was handled in three layers:
- staging standardization and parsing rules
- dbt tests for critical fields and accepted values
- Phase 11 validation script for cross-layer correctness and edge cases

The result is not only transformed data but measurable confidence indicators.

## 4. How were missing values treated?

Answer:
Missing and unknown values were preserved and made explicit. Placeholders such as k. A. were mapped to unknown/null in clean fields while keeping original raw fields for auditability. Ratio metrics include divide-by-zero protection, and dashboard quality pages expose missingness and transformation success rates.

## 5. How is public-sector value measured?

Answer:
Value is measured by decision usefulness:
- district-level gap prioritization
- delay-risk visibility for short-term planning
- inclusion coverage monitoring for legal and ethical obligations
- financial exposure visibility for delayed and temporary-heavy portfolios

This framework improves how planners sequence actions under budget and delivery constraints.

## 6. What are the main limitations?

Answer:
- Source scope is limited to available workbooks.
- Construction plans represent intended, not guaranteed, delivery.
- District-level analysis is coarser than catchment-level analysis.
- The system is descriptive and risk-oriented, not causal or predictive.

These limitations are documented so findings are interpreted as decision support signals, not deterministic forecasts.

## 7. How do you defend KPI correctness?

Answer:
KPI correctness is defended through:
- dbt model layering and explicit formulas
- dbt test coverage
- Phase 11 metric reconciliation across staging, intermediate, and marts
- reproducible QA evidence in reports/phase11_validation_report.json

## 8. How do you defend dashboard integrity?

Answer:
Each dashboard page is mapped to specific mart models and required fields. Phase 11 includes checks that verify model presence, required columns, and filter-column operability. This prevents disconnected visuals and undocumented metric logic.

## 9. Why include a data trust score?

Answer:
Public-sector decisions need context on confidence, not only point estimates. Data trust score exposes completeness and unknown-marker burden so stakeholders can weigh conclusions proportionally to data quality.

## 10. What would you improve first in a production rollout?

Answer:
First priorities would be:
- automated source refresh with stronger data contracts
- finer geospatial granularity
- scenario modeling for delivery-delay impacts
- integration of budget and procurement milestones