# Join Strategy Note
## Data Audit and Source Understanding

This document defines how the two source datasets (demand and construction) should be related for analysis. The guiding principle is: **never join across incompatible grains**. Instead, standardize and aggregate to a common grain before combining.

---

## 1. Source Grains (Recap)

- **Demand dataset**: one row per `Traeger` + `Bezirk` + `Schulart` (aggregated demand)
- **Construction dataset**: one row per `Berliner Schulnummer` (project-level supply)

Implication: direct row-level joins are invalid.

---

## 2. Canonical Dimensions (Normalization Layer)

Before any joins, create canonical dimensions in staging:

### 2.1 District (`Bezirk`)
- Trim whitespace
- Normalize casing
- Map to controlled vocabulary (12 Berlin districts)

### 2.2 School Type (`Schulart`)
- Trim whitespace
- Harmonize labels across datasets
- Map variants to canonical categories
- Flag special categories (e.g., temporary/interim sites)

### 2.3 Time (`Nutzungsübergabe` → year)
- Extract year (or start/end year) from strings like `2025/2026`
- Create `handover_year` (int) and optionally `handover_year_end`

---

## 3. Join Strategies by Use Case

### 3.1 District-Level Join (Baseline)

**Purpose**
- Overall demand vs. supply comparison
- District gap ranking

**Preparation**
- Aggregate demand to district level:
  - `sum(students)` by `Bezirk`
- Aggregate construction to district level:
  - `sum(planned_capacity)` by `Bezirk`
  - optionally filter to permanent projects only

**Join**
- Key: `Bezirk`
- Type: LEFT JOIN from demand → supply (to preserve demand coverage)

**Output Grain**
- one row per district

**Notes**
- This is the safest and first comparison layer.

---

### 3.2 District + School-Type Join (Core Analytical Layer)

**Purpose**
- Identify mismatches between demand and supply by school type
- Inclusion / specialization analysis

**Preparation**
- Aggregate demand:
  - `sum(students)` by `Bezirk`, `Schulart`
- Aggregate construction:
  - `sum(planned_capacity)` by `Bezirk`, `Schulart`
  - exclude or flag temporary categories (e.g., interim sites)

**Join**
- Keys: `Bezirk`, `Schulart`
- Type: FULL OUTER JOIN (recommended)
  - captures both unmet demand and oversupply

**Output Grain**
- one row per district + school type

**Critical Constraint**
- Requires **strict label harmonization** of `Schulart`

---

### 3.3 Time-Aware Join (Planning Horizon)

**Purpose**
- Compare current demand with future supply delivery
- Analyze delivery timelines and lag

**Preparation**
- Demand: typically static (snapshot year)
- Construction: derive `handover_year`
- Aggregate construction by:
  - `Bezirk`, `Schulart`, `handover_year`

**Join Options**
- Option A: join demand (static) to each future year slice
- Option B: cumulative capacity up to year N, then join

**Output Grain**
- `Bezirk` + `Schulart` + `handover_year`

---

### 3.4 Project-Level Analysis (No Direct Join)

**Purpose**
- Project risk, cost, and delivery analysis
- Data quality and anomaly detection

**Approach**
- Do **not** join to demand at row level
- Use dimensions (district, school type) for grouping

**Example**
- cost per capacity unit by project
- distribution of project sizes by district

---

### 3.5 Address / PLZ-Based Logic (Optional / Advanced)

**Purpose**
- Spatial approximation
- Proximity analysis
- Catchment-area heuristics

**Approach**
- Standardize `PLZ` and `Adresse`
- Optionally map to coordinates (external geocoding)
- Derive spatial joins (e.g., nearest district boundary if inconsistencies exist)

**Constraints**
- Not required for baseline analysis
- Adds complexity and external dependencies

---

## 4. Join Types Summary

| Use Case | Keys | Join Type | Grain |
|---|---|---|---|
| District comparison | Bezirk | LEFT | district |
| District + school type | Bezirk, Schulart | FULL OUTER | district + school type |
| Time-aware | Bezirk, Schulart, year | LEFT / FULL | district + school type + year |
| Project analysis | none (grouping only) | N/A | project |

---

## 5. Derived Metrics (Post-Join)

After joining at the correct grain, compute:

- `capacity_gap = demand_students - planned_capacity`
- `coverage_ratio = planned_capacity / demand_students`
- `surplus_flag = planned_capacity > demand_students`

Ensure null-safe handling:
- treat missing supply as 0
- treat missing demand explicitly (do not silently coalesce unless intended)

---

## 6. Anti-Patterns (Must Avoid)

- Joining project-level rows directly to aggregated demand rows
- Joining on raw `Schulart` without normalization
- Summing capacities across mixed temporary and permanent projects without filtering
- Performing joins before aggregation when grains differ

---

## 7. Implementation Blueprint (dbt-Oriented)

1. **stg_demand**
   - clean columns
   - standardize `Bezirk`, `Schulart`

2. **stg_construction**
   - clean columns
   - parse numeric fields
   - derive `handover_year`
   - standardize dimensions

3. **int_demand_agg**
   - aggregate to required grains

4. **int_construction_agg**
   - aggregate to required grains

5. **mart_gap_analysis**
   - join on chosen grain
   - compute metrics

---

## 8. Final Rule

> Always align both datasets to the same grain before joining. If the grains differ, aggregate first, then join.

