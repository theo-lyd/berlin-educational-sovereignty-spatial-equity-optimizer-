# Data Standardization and Business Rules

This document defines the normalization rules that make the source data analytically usable. The implementation should follow dbt best practices: keep staging models as the 1-to-1 entry point from the raw sources, use intermediate models for reusable transformation logic, and reserve marts for business-facing outputs. dbt also supports Jinja macros for reusable parsing and normalization logic, and built-in tests such as `not_null`, `unique`, `accepted_values`, and `relationships` for data quality enforcement. ([docs.getdbt.com](https://docs.getdbt.com/best-practices/how-we-structure/2-staging?utm_source=chatgpt.com))

---

## 1. Purpose 

The raw ingestion layer preserves source fidelity. Phase 6 converts those raw values into standardized analytical fields without losing traceability back to the source.

The guiding principle is:

> preserve raw truth in staging, then derive clean analytic fields in a controlled and testable way.

---

## 2. Standardization Principles

1. Keep the raw columns available for auditability.
2. Derive cleaned columns alongside the raw values.
3. Centralize recurring parsing rules in macros.
4. Normalize dimensions before any joins or aggregations.
5. Document every assumption explicitly.

---

## 3. Batch 6.1 — Normalize Numbers

### Goal
Convert text-based numeric values into consistent numeric fields wherever possible.

### Inputs to normalize
- `48 Mio.`
- `rund 27 Mio.`
- `k. A.`
- German-formatted decimal strings such as `1,5`
- values containing descriptive text plus a number
- year-range expressions where the business logic requires a derived year field

### Normalization rules

#### 3.1 Monetary amounts
- Remove qualifiers such as `rund`.
- Convert `Mio.` to a numeric multiplier of 1,000,000.
- Store the cleaned amount as an integer or decimal Euro value.
- Preserve the original string in a `_raw` column.

#### 3.2 Missing-value markers
- Treat `k. A.` as null.
- Treat empty strings as null.
- Do not infer values where the source explicitly indicates no information.

#### 3.3 German decimals
- Convert comma decimals to dot decimals before casting.
- Example: `1,5` → `1.5`.

#### 3.4 Textual ranges
- For values such as `2025/2026`, derive at least one normalized planning year field.
- Keep the original range string in a raw column for traceability.
- If the range cannot be safely collapsed into a single number, store start/end components separately.

### Expected outputs
- standardized numeric columns
- raw-value companion columns
- null-safe transformation logic

---

## 4. Batch 6.2 — Normalize District Labels

### Goal
Ensure district names are written consistently across both datasets.

### Rules
- Trim leading and trailing whitespace.
- Standardize casing.
- Map all district names to one canonical Berlin district vocabulary.
- Reject or flag unknown district values.

### Output fields
- `bezirk_clean`
- `bezirk_raw`

### Business rule
The district label is treated as a controlled analytical dimension. No downstream joins should use a raw district label.

---

## 5. Batch 6.3 — Normalize School-Type Labels

### Goal
Standardize school type categories so the demand and supply datasets can be compared reliably.

### Rules
- Trim whitespace.
- Normalize punctuation and spacing.
- Map source-specific variants to canonical categories.
- Separate true school types from project-measure categories.

### Canonical school-type dimension
Use a controlled vocabulary such as:
- Grundschule
- Gymnasium
- Integrierte Sekundarschule
- Gemeinschaftsschule
- OSZ
- Schule mit sonderpädagogischem Förderschwerpunkt
- Drehscheibe / interim-site flag as a project-classification attribute, not a school type

### Important distinction
`Drehscheibe` should not be treated as a normal school type. It should be modeled as an interim infrastructure classification.

### Output fields
- `schulart_clean`
- `schulart_raw`
- `is_special_needs`
- `is_temporary_site`

---

## 6. Batch 6.4 — Normalize Time Fields

### Goal
Make temporal fields analysis-ready.

### Fields to standardize
- `Nutzungsübergabe`
- project year
- snapshot dates

### Rules

#### 6.1 `Nutzungsübergabe`
- Preserve the source string.
- Derive a normalized planning year where possible.
- If the source is a range, store start and end components separately.
- Do not pretend a range is a precise date.

#### 6.2 Project year
- Derive a single planning year field for timeline visuals.
- If only a range is available, use the first year as the planning anchor and document that assumption.

#### 6.3 Snapshot dates
- Use snapshot timestamps for slowly changing fields.
- Store snapshot metadata as timestamps in UTC or a single project-standard timezone.

### Output fields
- `handover_period_raw`
- `handover_year_start`
- `handover_year_end`
- `snapshot_date`

---

## 7. Batch 6.5 — Business Rules

### 7.1 Missing costs

#### Rule
If cost is marked `k. A.` or cannot be parsed safely, store it as null.

#### Reason
A missing cost is materially different from a zero cost.

#### Downstream handling
- exclude null-cost projects from cost-per-seat calculations
- include them in data-quality metrics

---

### 7.2 Unknown values

#### Rule
Treat source placeholders such as `k. A.` as null, not as a literal category.

#### Reason
Unknown is not a valid analytical state.

#### Downstream handling
- preserve unknown frequency in the data trust score
- do not silently impute values unless explicitly modeled later

---

### 7.3 Special-needs records

#### Rule
Use the school-type vocabulary to identify special-needs records.

#### Suggested indicators
- `Schule mit sonderpädagogischem Förderschwerpunkt`
- school-type variants that clearly belong to special-needs provision

#### Downstream handling
- create a boolean `is_special_needs`
- allow separate aggregation for inclusion coverage analysis

---

### 7.4 Temporary-site projects

#### Rule
Classify projects such as `Drehscheibe` or `Temporäre Maßnahme` as temporary-site infrastructure.

#### Downstream handling
- create a boolean `is_temporary_site`
- exclude temporary-site capacity from permanent-supply rollups unless the analysis explicitly asks for total relief capacity
- analyze temporary projects separately for interim-cost exposure

---

### 7.5 Capacity fields

#### Rule
Where capacity is missing or non-parsable, keep null and do not infer from adjacent rows.

#### Reason
Capacity is a planning value, not a statistical estimate.

---

## 8. Derived Standard Fields

The standardized layer should expose fields such as:
- `bezirk_clean`
- `schulart_clean`
- `students`
- `planned_capacity`
- `planned_capacity_raw`
- `total_cost_eur`
- `total_cost_raw`
- `handover_year_start`
- `handover_year_end`
- `is_special_needs`
- `is_temporary_site`

These are the columns that will feed the intermediate models and marts.

---

## 9. Recommended Implementation Order

1. Build reusable dbt macros for parsing and normalization.
2. Update staging models to call those macros.
3. Add tests for cleaned dimensions and numeric fields.
4. Build intermediate models on the standardized fields.
5. Document any unresolved exceptions in the assumptions section.

---

## 10. Assumptions Log

Any rule that is not directly observable in the source data must be explicitly documented. Examples:
- how to reduce a year range to a single planning year
- how to classify mixed school-type labels
- how to distinguish permanent from temporary infrastructure

---

## 11. Deliverable for this Phase

The output of Phase 6 is a clean, documented standardized layer that can safely support:
- district-level joins
- school-type comparisons
- time-based projections
- special-needs coverage analysis
- financial risk analysis

