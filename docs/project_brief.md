# Project Brief  
## Berlin Educational Sovereignty & Spatial Equity Optimizer  

---

## 1. Project Title  

**Berlin Educational Sovereignty & Spatial Equity Optimizer**  
A data-driven decision support system for aligning student demand, school infrastructure planning, inclusion obligations, and public investment efficiency across Berlin’s districts.

---

## 2. Public-Sector Audience  

The primary stakeholder for this project is a Berlin public-sector education authority, such as:

- Senatsverwaltung für Bildung, Jugend und Familie (Berlin Senate Department for Education, Youth and Family)
- District-level school planning authorities (Bezirksämter)
- Public infrastructure and budget planning units

The system is designed for:
- policy analysts  
- infrastructure planners  
- education administrators  
- budget and investment decision-makers  

The outputs are tailored for **non-technical stakeholders** who require:
- interpretable metrics  
- district-level insights  
- decision-ready indicators  

---

## 3. Problem Statement  

Berlin’s education system faces increasing pressure from:

- uneven student population growth across districts  
- delayed school infrastructure delivery  
- reliance on temporary facilities (e.g., Drehscheiben, modular units)  
- legal obligations to provide inclusive (special-needs) education  
- budget constraints and capital allocation inefficiencies  

Current planning approaches often treat **demand, capacity, cost, and timelines as separate dimensions**, leading to:

- spatial misalignment (capacity added in the wrong districts)  
- temporal mismatch (capacity delivered too late)  
- financial inefficiency (prolonged temporary-site usage)  
- inclusion gaps (insufficient special-needs provision)  

This project addresses the need for an **integrated analytical system** that answers:

> Where is educational capacity needed, when is it needed, for which school types, at what cost, and with what risk to equity and compliance?

---

## 4. Core Research Questions  

The project is structured around five analytical domains:

### 4.1 Demand–Supply Alignment  
- Which districts have the largest gaps between student demand and planned capacity?  
- Which school types are under-provisioned relative to demand?  

### 4.2 Temporal Risk (Handover Delay)  
- Which districts depend on infrastructure that will not be delivered in the short term?  
- How does capacity evolve across planning horizons (e.g., 2025–2027)?  

### 4.3 Financial Efficiency  
- Where are temporary sites likely to become long-term cost burdens?  
- How does interim-site cost exposure compare to permanent infrastructure investment?  

### 4.4 Inclusion Integrity  
- Are special-needs (Förderschwerpunkt) capacities aligned with demand across districts?  
- Which districts face potential legal or ethical risks due to insufficient inclusion coverage?  

### 4.5 Spatial Equity  
- Are infrastructure investments aligned with geographic demand distribution?  
- Which districts are structurally underinvested despite high demand?  

---

## 5. Project Objectives  

### Primary Objective  
To design and implement an end-to-end analytics engineering system that integrates student demand and school construction data to identify:

- capacity gaps  
- delivery delays  
- inclusion coverage issues  
- spatial inequities  
- financial inefficiencies  

---

### Secondary Objectives  

1. Quantify district-level demand–supply gaps  
2. Model capacity delivery timelines and delay exposure  
3. Evaluate the cost and dependency of temporary infrastructure  
4. Measure inclusion coverage for special-needs education  
5. Track planning changes over time using historical snapshots  
6. Provide an interactive dashboard for decision support  
7. Demonstrate an industry-standard analytics pipeline  

---

## 6. Final Deliverables  

The project will produce the following outputs:

### 6.1 Data & Analytics Layer  
- Cleaned and standardized datasets (DuckDB)  
- dbt models (staging, intermediate, marts)  
- Historical snapshots of planning changes  
- Data quality and validation reports  

### 6.2 Pipeline & Infrastructure  
- Python-based data ingestion scripts  
- Airflow DAG for orchestration  
- Reproducible analytics pipeline  

### 6.3 Dashboard & Reporting  
- Interactive dashboards (Metabase) including:
  - district capacity gaps  
  - delivery timeline analysis  
  - inclusion coverage  
  - project risk assessment  
  - data trust indicators  

### 6.4 Documentation  
- Project README (GitHub)  
- Data dictionary  
- KPI definitions  
- Methodology documentation  
- Architecture overview  

### 6.5 Thesis & Presentation  
- Capstone thesis report  
- Executive presentation slides  
- Stakeholder-oriented narrative  

---

## 7. Success Criteria  

The project will be considered successful if it can:

### Analytical Success
- Accurately quantify demand–supply gaps across all districts  
- Identify high-risk districts based on delay and underinvestment  
- Detect inclusion gaps for special-needs education  
- Provide a consistent and validated KPI framework  

### Engineering Success
- Deliver a reproducible pipeline using DuckDB, dbt, Python, and Airflow  
- Implement data quality checks and validation mechanisms  
- Track historical changes using snapshotting  
- Maintain a modular and scalable data model  

### Stakeholder Success
- Present insights in a clear, decision-ready format  
- Enable district-level comparisons and prioritization  
- Highlight financial and legal risk areas  
- Support evidence-based public-sector decision-making  

### Academic Success (Thesis Defense)
- Demonstrate sound methodology and system design  
- Justify technology choices and modeling decisions  
- Clearly articulate assumptions and limitations  
- Provide reproducible and well-documented results  

---

## 8. Project Constraints and Assumptions  

### Constraints
- Limited dataset scope (two primary Excel sources)  
- Data quality issues (e.g., missing values, “k. A.” entries)  
- No real-time data updates  
- Codespaces resource limitations (compute, storage, runtime)  

### Assumptions
- District-level aggregation is sufficient for decision analysis  
- School-type categories can be standardized across datasets  
- Construction plans represent intended (not guaranteed) outcomes  
- Spatial proximity is approximated at district/PLZ level  

---

## 9. Technology Stack  

The project is implemented using:

- **DuckDB** – analytical data storage and querying  
- **dbt (data build tool)** – data transformation, testing, and modeling  
- **Python** – ingestion, preprocessing, and auxiliary analysis  
- **Airflow** – orchestration and scheduling  
- **Metabase** – dashboarding and reporting  
- **GitHub Codespaces** – cloud-based development environment  

---

## 10. Positioning Statement  

This project is positioned as an **analytics engineering solution for public-sector decision support**, combining:

- data modeling  
- pipeline engineering  
- KPI design  
- policy-relevant analytics  

to deliver a **transparent, reproducible, and decision-oriented system** for educational infrastructure planning in Berlin.

---