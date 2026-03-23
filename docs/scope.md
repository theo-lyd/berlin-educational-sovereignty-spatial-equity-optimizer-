# Scope Definition  
## Berlin Educational Sovereignty & Spatial Equity Optimizer  

---

## 1. Purpose of Scope Definition  

This document defines the **analytical, technical, and functional boundaries** of the project. It explicitly states what is included and excluded to ensure:

- clarity of implementation  
- controlled project complexity  
- alignment with thesis expectations  
- defensibility during evaluation  

---

## 2. Datasets in Scope  

The project uses two primary datasets:

### 2.1 Student Demand Dataset  
**File:** `od-eckdaten-allg-2024.xlsx`  

**Description:**  
District-level student enrollment data across Berlin, segmented by school type and provider.

**Key Fields (Representative):**
- district (Bezirk)  
- school type (Schulart)  
- provider (Träger)  
- total students (Schüler w/m/d)  

**Analytical Role:**  
- Represents **current demand baseline**  
- Used for district-level and school-type-level demand analysis  
- Used for inclusion (special-needs) demand estimation  

---

### 2.2 School Infrastructure Dataset  
**File:** `schulbaukarte-2025-.xlsx`  

**Description:**  
Project-level data describing planned and ongoing school construction measures in Berlin.

**Key Fields (Representative):**
- school identifier  
- district  
- school type  
- construction measure  
- capacity before/after construction  
- track count (Zügigkeit)  
- handover date (Nutzungsübergabe)  
- cost (Gesamtkosten)  
- address and PLZ  

**Analytical Role:**  
- Represents **planned and future supply**  
- Used for capacity, cost, timing, and spatial analysis  
- Used for risk and investment evaluation  

---

## 3. Metrics in Scope  

The project will compute metrics across four domains:

---

### 3.1 Demand Metrics  

- total students per district  
- students per school type  
- special-needs student demand  
- district demand share  

---

### 3.2 Supply Metrics  

- planned capacity (post-construction)  
- capacity increase per project  
- capacity delivery by year  
- Zügigkeit after construction  
- project-level capacity contribution  

---

### 3.3 Gap and Equity Metrics  

- district demand–supply gap  
- school-type demand–supply gap  
- inclusion coverage rate  
- spatial relief score (district-level approximation)  
- underinvestment index (high demand, low planned capacity)  

---

### 3.4 Risk and Financial Metrics  

- delay exposure (based on handover timelines)  
- interim-site dependency indicator (Drehscheiben / temporary measures)  
- project criticality score  
- financial exposure (based on cost and delay interaction)  
- planning slippage (via snapshot comparison)  

---

### 3.5 Data Quality Metrics  

- completeness rate  
- null/missing value rate  
- frequency of “k. A.” entries  
- valid vs invalid records  
- overall data trust score  

---

## 4. Visualizations in Scope  

The dashboard will include decision-oriented visualizations grouped by analytical purpose.

---

### 4.1 Executive Overview  

- KPI cards (total demand, total capacity, gap, risk indicators)  
- high-level summary charts  

---

### 4.2 District Comparison  

- bar chart: demand vs planned capacity by district  
- ranked table of districts by gap  
- heatmap of district performance  

---

### 4.3 Capacity Timeline  

- capacity delivery by year (line or bar chart)  
- gap reduction over time (burn-up / burn-down style)  

---

### 4.4 Inclusion Coverage  

- district-level comparison of special-needs demand vs supply  
- coverage ratio visualization  
- gap highlighting table  

---

### 4.5 Financial and Risk Analysis  

- project risk ranking table  
- delayed project indicators  
- cost distribution across projects  
- temporary vs permanent measure comparison  

---

### 4.6 Zügigkeit Analysis  

- scatter plot:
  - X-axis: student demand  
  - Y-axis: planned tracks (Zügigkeit)  
- identification of under-tracked and over-tracked cases  

---

### 4.7 Data Quality Dashboard  

- completeness metrics  
- missing value distribution  
- invalid data indicators  
- data trust score visualization  

---

## 5. Functional Scope  

The system will include:

- reproducible data ingestion pipeline (Python + DuckDB)  
- transformation layer using dbt  
- data quality validation (dbt tests)  
- historical tracking using dbt snapshots  
- orchestration using Airflow  
- dashboarding using Metabase  
- version-controlled codebase (GitHub)  

---

## 6. Explicitly Out of Scope  

The following are **intentionally excluded** to control complexity and maintain focus:

---

### 6.1 Advanced Geospatial Analysis  

- no GIS-based routing or travel-time calculations  
- no real-time distance optimization  
- no integration with external geospatial APIs  

**Reason:**  
Spatial analysis is limited to district/PLZ-level approximation.

---

### 6.2 Real-Time or Streaming Data  

- no live data ingestion  
- no streaming pipelines  

**Reason:**  
The project is based on static planning datasets.

---

### 6.3 External Data Enrichment  

- no demographic datasets beyond provided files  
- no socioeconomic or income data  
- no population forecasts  

**Reason:**  
Focus remains on internal planning alignment rather than external modeling.

---

### 6.4 Predictive Modeling / Machine Learning  

- no forecasting models  
- no predictive enrollment modeling  
- no optimization algorithms  

**Reason:**  
The project focuses on **descriptive and diagnostic analytics**, not predictive modeling.

---

### 6.5 Full Production Deployment  

- no cloud production deployment (e.g., AWS, GCP)  
- no CI/CD pipeline implementation beyond basic version control  
- no enterprise-grade security or authentication  

**Reason:**  
The project is a capstone prototype, not a production system.

---

### 6.6 User Authentication and Multi-User Access  

- no role-based access control  
- no multi-user system design  

**Reason:**  
The dashboard is intended for demonstration and evaluation.

---

## 7. Assumptions  

- district-level aggregation is sufficient for policy insights  
- school-type categories can be harmonized across datasets  
- planned construction data reflects intended capacity outcomes  
- missing data can be handled through standard cleaning strategies  
- temporal analysis is based on planned (not guaranteed) timelines  

---

## 8. Scope Boundaries Summary  

| Area                     | Included | Excluded |
|--------------------------|---------|---------|
| Demand Analysis          | Yes     | —       |
| Supply Analysis          | Yes     | —       |
| Gap & Equity Analysis    | Yes     | —       |
| Risk & Cost Analysis     | Yes     | —       |
| Data Quality Analysis    | Yes     | —       |
| Geospatial Precision     | Limited | Advanced GIS |
| Real-Time Processing     | No      | Yes     |
| Machine Learning         | No      | Yes     |
| Production Deployment    | No      | Yes     |

---

## 9. Scope Justification  

This scope is designed to:

- maximize analytical depth within limited datasets  
- demonstrate strong analytics engineering practices  
- remain feasible within GitHub Codespaces constraints  
- produce a defensible, high-quality capstone thesis  
- deliver clear value to public-sector stakeholders  

---