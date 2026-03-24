# Dashboard Question Bank and Build Batches

## 1) Full Question Bank: Business + Analytical + Data-Layer

### A. Strategic business questions (decision-facing)
- Which districts have the largest student-seat gaps right now?
- Where is demand pressure above sustainable levels?
- Which districts are most exposed to delayed project delivery?
- How much planned capacity arrives each year, and is it mostly temporary or permanent?
- Where are special-needs students under-covered relative to planned capacity?
- Which high-cost projects are both delayed and high risk?
- Which districts rely too heavily on temporary sites?
- How strong is the overall data trust level for decision-making?
- Which district-school-type combinations are structurally under-provisioned?
- Are planned tracks (Zugigkeit) aligned with student volumes?

### B. Analytical KPI questions (model-facing)
- Total demand vs total planned capacity vs total gap.
- District gap totals and district demand shares.
- Demand pressure ratio by district.
- Spatial relief score by district.
- Yearly and cumulative capacity delivery.
- Project count bottlenecks by delivery year.
- Inclusion coverage ratio and inclusion gap by district.
- Risk bucket distribution by district.
- Delayed handover count by district.
- Expensive delayed project portfolio and risk rank.
- Track-per-student ratio by district and school type.
- Model-level missingness, invalid rates, k.A. rates, transformation success, trust score.

### C. Raw and staging schema questions (diagnostic-facing)

Raw data questions:
- Are there duplicate rows or duplicated business keys?
- How many missing district, school type, handover, and cost fields exist?
- Are there impossible values (negative demand/capacity/cost)?
- Are date formats and period fields consistent?
- How often do placeholder tokens appear (for example k. A.)?
- Are temporary/permanent indicators complete and valid?
- Is demand data coverage balanced across districts and school types?

Staging questions:
- Which raw values failed normalization and mapping?
- What percentage of records was standardized successfully?
- Which districts or school types remain unmapped after cleaning?
- How much row-loss occurred from raw to staging and why?
- Which critical fields are still null after staging logic?
- Are join keys stable between staging demand and staging projects?
- Do staged cost and date fields pass type and range checks?

### D. Edge cases and hidden-insight questions
- Districts that look average overall but have severe school-type sub-gaps.
- High-capacity districts with poor relief because delivery is too late.
- Districts with acceptable totals but unsafe inclusion coverage.
- Projects with moderate cost but extreme risk due to timing and temporary dependency.
- Data confidence asymmetry: one model very clean, another weak, distorting combined KPIs.
- Capacity concentration risk: many projects clustered in one year creates delivery fragility.
- Outlier track-per-student ratios that suggest planning inefficiency.
- False comfort scenario: improved headline gap driven by temporary sites only.

## 2) Batches and Chunks Plan

### Batch 1: Executive and district pressure core
- Chunk 1. Executive KPI cards and high-risk table
- Chunk 2. District gap and pressure visuals
- Chunk 3. Spatial relief and district demand share

### Batch 2: Delivery timeline and bottleneck risk
- Chunk 1. Capacity by year and temporary/permanent split
- Chunk 2. Cumulative burn-up and project concentration
- Chunk 3. Missing metadata by year

### Batch 3: Inclusion and equity risk
- Chunk 1. Special-needs demand and planned capacity
- Chunk 2. Inclusion coverage ratio and gap table
- Chunk 3. Equity exception views (hidden shortfalls)

### Batch 4: Financial and interim risk
- Chunk 1. Risk heatmap and delayed handover by district
- Chunk 2. High-cost delayed portfolio table
- Chunk 3. Risk-rank vs cost scatter

### Batch 5: Zugigkeit alignment
- Chunk 1. Student volume vs planned tracks scatter
- Chunk 2. Track-per-student ratio by district
- Chunk 3. District-school-type detail table

### Batch 6: Data trust and diagnostics
- Chunk 1. Trust score, missingness, invalid rates
- Chunk 2. Transformation success and incompleteness
- Chunk 3. Raw/staging diagnostic board

## 3) Spec-completeness additions to include

Yes, add the following so the question inventory is fully aligned with the project dashboard specification:

- Explicit question on projects missing cost and handover metadata by year.
- Explicit district-by-school-type gap matrix question (heatmap/pivot requirement).
- Explicit transformation success and incomplete records scorecard as a full model-level table.
- Explicit drill-down behavior question (district click should filter downstream visuals).
- Explicit threshold question definitions for each ratio chart (for example 1.0 pressure line, inclusion 1.0 line, track ratio banding).
