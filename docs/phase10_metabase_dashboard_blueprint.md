# Phase 10 — Metabase Dashboard Blueprint

This blueprint maps each required dashboard to a dbt KPI dataset, recommended visualization type, filters, and key stakeholder interpretation.

---

## 1. Executive Overview Dashboard

**Purpose:** citywide summary of demand, planned capacity, gap, risk, and data confidence.

**Primary dataset:**
- `analytics_marts.kpi_executive_overview`

**Tiles:**
- Total student demand (single value)
- Total planned capacity (single value)
- Total gap (single value)
- High-risk district count (single value)
- Overall data trust score (single value)

**Optional supporting chart:**
- Top high-risk districts from `analytics_marts.kpi_delay_risk_dashboard` (table, filter to `project_risk_bucket = 'high'`)

**Recommended Metabase visuals:**
- **Number cards** for five KPI tiles (5 separate questions)
- **Table** for high-risk district summary (top 10 high-risk projects by cost)

---

## 2. District Comparison Dashboard

**Purpose:** compare the 12 Berlin districts by demand, capacity, gap, and risk profile.

**Primary dataset:**
- `analytics_marts.kpi_district_comparison`

**Visuals:**

A. **District Ranking by Gap** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `district_gap_total`
   - sorted descending by gap
   - filter: `schulart_clean = <selected school type>` (optional filter widget)

B. **Demand vs Planned Capacity by District** (grouped bar chart)
   - x-axis: `bezirk_clean`
   - y-axis (left): `district_demand_total`
   - y-axis (right): `district_capacity_total`
   - legend: demand (blue), capacity (green)

C. **District Demand Share** (pie or donut chart)
   - segments: `bezirk_clean`
   - values: `demand_share_pct`
   - shows % of Berlin-wide demand concentrated in each district

D. **District Demand Pressure Ratio** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `demand_pressure_ratio` (students per seat)
   - threshold line at 1.0 (supply = demand)
   - conditional coloring: green (≤1.0), yellow (1.0–1.5), red (>1.5)

E. **Spatial Relief Score by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `spatial_relief_score` (% of gap that capacity covers)
   - color: green (≥80%), yellow (50–80%), red (<50%)
   - shows effectiveness of planned capacity in closing district gaps

F. **Gap by District and School Type** (heatmap or pivot table)
   - rows: `bezirk_clean`
   - columns: `schulart_clean`
   - values: `gap_total`
   - cell coloring: neutral (0), warning (0–500 gap), critical (≥500 gap)

**Filters:**
- district (`bezirk_clean`)
- school type (`schulart_clean`)
- gap range slider

---

## 3. Delivery Timeline Dashboard

**Purpose:** show when capacity is expected to be delivered and how it closes gaps over time.

**Primary dataset:**
- `analytics_marts.kpi_delivery_timeline`

**Visuals:**

A. **Capacity Delivery by Year** (stacked bar chart)
   - x-axis: `delivery_year`
   - y-axis: `planned_capacity_total`
   - stacked: permanent (green) vs temporary (orange/red)
   - shows year-by-year capacity additions

B. **Cumulative Capacity Burn-Up Chart** (line chart)
   - x-axis: `delivery_year`
   - y-axis (left): `cumulative_capacity_permanent` + `cumulative_capacity_temporary` (trend line)
   - y-axis (right): `project_count` (scatter or bar overlay)
   - shows total planned capacity accumulation over time

C. **Project Count by Delivery Year** (bar chart)
   - x-axis: `delivery_year`
   - y-axis: `project_count`
   - shows concentration of handover timing (identifies delivery bottlenecks)

D. **Projects Missing Cost or Handover Metadata** (bar chart)
   - x-axis: `delivery_year`
   - y-axis: `projects_missing_cost`, `projects_missing_handover_period` (grouped)
   - highlights data quality risks in future delivery estimates

**Filters:**
- delivery year range
- capacity type (permanent vs temporary)

---

## 4. Inclusion (Special-Needs) Coverage Dashboard

**Purpose:** assess special-needs education coverage and identify districts with legal risk exposure.

**Primary dataset:**
- `analytics_marts.kpi_inclusion_coverage`

**Visuals:**

A. **Special-Needs Demand by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `special_needs_demand_students`
   - sorted descending
   - highlights districts with highest special-needs student concentration

B. **Special-Needs Planned Capacity by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `special_needs_planned_capacity`
   - overlay with permanent vs temporary breakdown

C. **Inclusion Coverage Ratio by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `special_needs_coverage_ratio`
   - reference line at 1.0 (100% coverage)
   - conditional coloring: green (≥1.0), yellow (0.8–1.0), red (<0.8)
   - identifies districts at legal risk (underprovision)

D. **Inclusion Gap by District** (table)
   - rows: `bezirk_clean`
   - key columns: `special_needs_demand_students`, `special_needs_planned_capacity`, `special_needs_gap_total`
   - sorts by gap DESC
   - highlight rows where gap > 0 (red) or coverage < 100% (yellow)

**Filters:**
- district

---

## 5. Financial and Interim Risk Dashboard

**Purpose:** expose capital inefficiency, cost exposure, and interim-site dependency.

**Primary dataset:**
- `analytics_marts.kpi_delay_risk_dashboard`

**Visuals:**

A. **Projection Risk Heatmap** (matrix/heatmap)
   - rows: `bezirk_clean`
   - columns: `project_risk_bucket` (high, medium, low)
   - cell values: count of projects per bucket
   - cell coloring: red (high), yellow (medium), green (low)
   - shows risk concentration by district

B. **Delayed Handover by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: count of projects where `delayed_handover_flag = true`
   - identifies districts facing near-term capacity shortfalls

C. **Interim-Site Dependency Portfolio** (stacked bar or grouped bar chart)
   - x-axis: `bezirk_clean`
   - y-axis (stacked): count of temporary sites vs permanent
   - or grouped by `is_temporary_site` flag
   - shows reliance on interim arrangements by district

D. **High-Cost Delayed Projects** (table)
   - rows: projects where `expensive_delayed_project_flag = true`
   - key columns: `school_name`, `bezirk_clean`, `schulart_clean`, `handover_year_start`, `total_cost_eur`, `project_risk_bucket`, `project_risk_rank`
   - sorted by cost DESC
   - conditional coloring: red row background for expensive delayed (>€15M + delay flag)

E. **Project Risk Rank by Cost** (scatter or bubble chart)
   - x-axis: `total_cost_eur`
   - y-axis: `project_risk_score`
   - bubble size (optional): `planned_capacity`
   - series/color: `project_risk_bucket`
   - identifies which high-cost projects carry highest risk

**Recommended filters:**
- district
- risk bucket (high/medium/low)
- delay flag (true/false)
- cost range slider

---

## 6. Zügigkeit vs Demand Dashboard

**Purpose:** evaluate whether planned tracks align with student volume and identify overtrack/undertrack schools.

**Primary dataset:**
- `analytics_marts.kpi_zugigkeit_scatter`

**Visuals:**

A. **Scatter Plot: Student Volume vs Planned Tracks** (scatter or bubble chart)
   - x-axis: `student_volume`
   - y-axis: `planned_track_count`
   - bubble size (optional): `planned_capacity_total`
   - series/color: `bezirk_clean` or `schulart_clean`
   - reference line: `track_per_student_ratio = 0.2` (approx. 5 students per track)
   - quadrant analysis:
     - High volume, low tracks (undertracked, bottom-right): risk
     - High volume, high tracks (overtracked, top-right): efficiency question
     - Low volume, high tracks (overtracked, top-left): efficiency
     - Low volume, low tracks (normal, bottom-left): baseline

B. **Track-to-Student Ratio by District** (bar chart)
   - x-axis: `bezirk_clean`
   - y-axis: `track_per_student_ratio`
   - reference line at 0.2 (1 track per 5 students)
   - conditional coloring: green (0.18–0.22), yellow (0.15–0.18 or 0.22–0.25), red (<0.15 or >0.25)

C. **District and School-Type Detail Table**
   - rows: unique combinations of `bezirk_clean` × `schulart_clean`
   - columns: `student_volume`, `planned_track_count`, `avg_track_count`, `track_per_student_ratio`, `project_count`
   - sorted by `track_per_student_ratio`
   - highlights under/over-provisioned combinations

**Filters:**
- district
- school type
- volume range slider

---

## 7. Data Trust and Audit Dashboard

**Purpose:** make the reliability of the dashboard transparent to stakeholders.

**Primary dataset:**
- `analytics_marts.kpi_data_quality_dashboard` (primary)
- `analytics_marts.kpi_data_trust_score` (supporting)

**Visuals:**

A. **Data Trust Score** (number card)
   - metric: `data_trust_score` where `model_name = 'overall'`
   - displays overall confidence % for the entire pipeline
   - color-coded: green (≥90%), yellow (70–90%), red (<70%)

B. **Missing Value Rate by Model** (bar chart)
   - x-axis: `model_name` (stg_student_demand, stg_school_construction_projects)
   - y-axis: `missing_value_rate_pct`
   - threshold line at 5%

C. **Invalid Value Rate by Model** (bar chart)
   - x-axis: `model_name`
   - y-axis: `invalid_value_rate_pct`
   - highlights data entry errors

D. **Unknown ("k. A.") Marker Rate by Model** (bar chart)
   - x-axis: `model_name`
   - y-axis: `ka_rate_pct`
   - shows ambiguous/coded "not applicable" prevalence

E. **Transformation Success Rate by Model** (bar chart)
   - x-axis: `model_name`
   - y-axis: `transformation_success_rate`
   - color-coded: green (≥95%), yellow (80–95%), red (<80%)
   - shows % of records with all required fields populated post-standardization

F. **Incomplete Records Rate by Model** (gauge or mini bar)
   - displays `incomplete_project_rate_pct` per model
   - warns of missing critical dimensions

G. **Data Quality Scorecard** (single table)
   - rows: model_name
   - columns: row_count, missing_value_rate, invalid_value_rate, ka_rate, transformation_success_rate, data_trust_score
   - conditional cell formatting (red/yellow/green based on thresholds)

**Supporting dataset for confidence:**
- `analytics_marts.kpi_data_trust_score` — for detailed completeness_pct, missingness_pct per model
  - x-axis: `model_name`
  - y-axis: `data_trust_score` (line chart)
  - overlay: `completeness_pct` (secondary axis)

**Filters:**
- model_name (to drill down into specific staging table quality)

---

## 8. Visual Summary: Core Outputs Mapped to Metabase Charts

| **Spec. Section** | **Visual Name** | **Metabase Type** | **Primary Field** | **Page** |
|---|---|---|---|---|
| 9.3.A | Gap Closing Timeline | Line (burn-up) + Bar (stacked) | cumulative_capacity, delivery_year | Delivery Timeline |
| 9.3.B | Risk Heatmap | Heatmap/Matrix | project_risk_bucket × bezirk | Financial Risk |
| 9.3.C | Inclusion Coverage Map | Heatmap/Bar Matrix | special_needs_gap × bezirk | Inclusion |
| 9.3.D | Zügigkeit Scatter | Scatter + Bubble | student_volume × planned_track_count | Zügigkeit |
| 9.3.E | Project Priority Table | Table (ranked) | project_risk_rank, cost, delay_flag | Financial Risk |

---

## 9. Public-Sector Presentation Guidance

- **Use clear labels** in plain language; avoid technical abbreviations on titles (e.g., use "Special-Needs Students" not "SN Demand").
- **Prefer district-first views** to match administrative responsibilities.
- **Keep one decision question per chart**; avoid information overload.
- **Use conditional coloring** for gaps/risk: 
  - Green = healthy (gap < demand, coverage > 100%, ratio 0.15–0.25)
  - Yellow = watch (moderate gap/shortfall)
  - Red = critical (large gap, underprovision, high risk)
- **Pin data trust score** near top-level KPI cards to contextualize confidence.
- **Sort tables descending by impact** (gap, cost, risk, need) unless district order is required.
- **Add filter widgets** for district, school type, and risk bucket on all compatible cards.

---

## 10. Metabase Build Sequence

1. **Sync metadata** for DuckDB connection; verify all 6 KPI tables are discoverable.
2. **Create saved questions** from each KPI mart (1–2 questions per visual spec above).
3. **Build dashboard pages** in order:
   - Executive Overview (KPI cards + high-risk table)
   - District Comparison (6 visuals)
   - Delivery Timeline (4 visuals) ← NEW
   - Inclusion (4 visuals)
   - Financial & Interim Risk (5 visuals)
   - Zügigkeit (3 visuals)
   - Data Trust & Audit (7 visuals)
4. **Add filter widgets** (district, school type, risk bucket, year/cost sliders) and cascade across compatible cards.
5. **Validate all numbers** against direct SQL outputs in dbt before stakeholder sharing.
6. **Set drill-down capabilities** (e.g., clicking a district in Executive page should filter all downstream pages).

---

## 11. KPI Completeness Checklist

All 17 KPIs from the specification are now covered:

**Demand (3):**
- [x] Total Student Demand → `kpi_executive_overview`, `kpi_district_comparison`
- [x] Special-Needs Demand → `kpi_inclusion_coverage`
- [x] District Demand Share → `kpi_district_comparison.demand_share_pct`

**Supply (4):**
- [x] Planned Capacity → all mart tables
- [x] Capacity Additions by Year → `kpi_delivery_timeline`
- [x] Zügigkeit After Construction → `kpi_zugigkeit_scatter.planned_track_count`
- [x] Supply Coverage Rate → `demand_pressure_ratio` in `kpi_district_comparison`

**Equity (3):**
- [x] District Gap Score → `kpi_district_comparison.district_gap_total`
- [x] Inclusion Coverage Rate → `kpi_inclusion_coverage.special_needs_coverage_ratio`
- [x] Spatial Relief Score → `kpi_district_comparison.spatial_relief_score`

**Risk (4):**
- [x] Delay Exposure → `kpi_delay_risk_dashboard.delayed_handover_flag`
- [x] Interim-Site Dependency Risk → `kpi_delay_risk_dashboard.is_temporary_site`, `expensive_delayed_project_flag`
- [x] Planning Slippage → `kpi_delay_risk_dashboard` (delta fields), `kpi_planning_slippage`
- [x] Financial Exposure → `kpi_delay_risk_dashboard` (cost thresholds, ≥€15M logic)

**Data Quality (3):**
- [x] Data Trust Score → `kpi_data_trust_score`, `kpi_data_quality_dashboard`
- [x] Completeness Rate → `kpi_data_trust_score.completeness_pct`, `kpi_data_quality_dashboard`
- [x] Transformation Success Rate → `kpi_data_quality_dashboard.transformation_success_rate`


