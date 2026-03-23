# Grain Definition
## Data Audit and Source Understanding

This document defines the grain of each source table. Grain means the level of detail represented by one row.

Getting the grain correct is essential because all joins, aggregations, and KPI calculations depend on it.

---

## 1. Demand Dataset Grain

### Source File
`od-eckdaten-allg-2024.xlsx`

### Grain Statement
**One row represents one unique combination of provider (`Traeger`), district (`Bezirk`), and school type (`Schulart`) with the associated student count (`Schüler (w/m/d)`).**

### Practical Interpretation
This is a **district-level demand table** segmented by:
- provider type
- Berlin district
- school type

### Why this grain matters
- It is not a student-level dataset.
- It is not a school-level dataset.
- It is an aggregated planning table.
- The student count is already summarized at the row level.

### Safe aggregation logic
Because one row already represents an aggregated category combination, future analysis should only aggregate upward from this grain, for example:
- by district
- by school type
- by provider
- by district and school type

### Do not do
- Do not sum the same row multiple times after joining to a more detailed table.
- Do not assume the table contains one record per school.
- Do not assume a single district-school-type combination appears more than once unless duplicate validation proves it.

---

## 2. Construction Dataset Grain

### Source File
`schulbaukarte-2025-.xlsx`

### Grain Statement
**One row represents one school construction or infrastructure project, identified primarily by `Berliner Schulnummer`, with associated project attributes such as district, school type, construction measure, capacity, cost, and handover period.**

### Practical Interpretation
This is a **project-level supply table**.
Each row describes one planned, ongoing, temporary, or completed construction action tied to one school/project record.

### Why this grain matters
- It is not a district summary table.
- It is not a school-type summary table.
- It is a project inventory table.
- Several project attributes are specific to that one record and should not be aggregated before cleaning.

### Safe aggregation logic
From this grain, you may aggregate upward to:
- district level
- school type level
- handover year level
- construction measure type level
- temporary vs permanent measure level

### Do not do
- Do not treat this table as one row per district.
- Do not sum capacities or costs without checking whether projects overlap conceptually.
- Do not merge onto the demand table before harmonizing school-type labels and checking temporary-site categories.

---

## 3. Comparison of Grains

| Dataset | Grain | Type |
|---|---|---|
| Demand dataset | one provider-district-school-type combination | aggregated demand table |
| Construction dataset | one school construction project | project-level supply table |

### Important implication
The two datasets are at **different analytical grains**.
This means they should not be joined blindly.

A direct row-by-row join is incorrect because:
- the demand dataset is aggregated at category level
- the construction dataset is project-level

Instead, both datasets should be standardized and then aggregated to a common comparison level such as:
- district
- district + school type
- district + planning horizon

---

## 4. Recommended Common Comparison Grains

For the final analytical layer, use the following common grains depending on the question:

### A. District grain
Use for:
- overall demand vs supply comparison
- district gap ranking
- heatmaps and executive summary visuals

### B. District + school type grain
Use for:
- school-type-specific gap analysis
- inclusion coverage
- Zügigkeit mismatch analysis

### C. District + year grain
Use for:
- handover timeline
- capacity delivery analysis
- planning slippage view

### D. Project grain
Use for:
- project risk scoring
- cost analysis
- interim-site analysis
- data quality review

---

## 5. Modeling Rule Derived from the Grain

Before any join or KPI calculation, always ask:

1. What is the grain of the left table?
2. What is the grain of the right table?
3. Are they compatible?
4. If not, should one or both be aggregated first?

If the answer to compatibility is no, the transformation must first create an intermediate table at the correct common grain.

---

## 6. Final Grain Statements

### Demand dataset
**Grain:** one row per `Traeger` + `Bezirk` + `Schulart` combination.

### Construction dataset
**Grain:** one row per school construction project, identified primarily by `Berliner Schulnummer`.

---

## 7. Implementation Note

These grain definitions should be treated as source-of-truth documentation for:
- dbt staging models
- intermediate aggregation logic
- dashboard metric definitions
- thesis methodology write-up

