# Methodology  
## Berlin Educational Sovereignty & Spatial Equity Optimizer  

---

## 1. Methodological Overview  

This project follows a structured **analytics engineering methodology** designed to ensure:

- data correctness before insight generation  
- reproducibility of all transformations  
- transparency of assumptions and logic  
- alignment with public-sector decision-making needs  

The implementation is guided by a strict sequencing principle:

> **Clean Data → Correct Metrics → Automated Pipeline → Decision Dashboard → Presentation Optimization**

Each stage builds on the integrity of the previous one. No stage is advanced until the prior stage is validated.

---

## 2. Core Implementation Philosophy  

### 2.1 Data First, Not Dashboard First  
The project prioritizes **data integrity over visualization speed**.  
All transformations are validated before any dashboard is created.

**Rationale:**  
Incorrect data leads to misleading public-sector decisions, regardless of how well it is visualized.

---

### 2.2 Reproducibility as a Requirement  
All transformations are implemented using:
- SQL (via DuckDB)  
- dbt models  

No manual data manipulation is allowed outside the pipeline.

**Rationale:**  
Ensures that results are:
- reproducible  
- auditable  
- version-controlled  

---

### 2.3 Modular Data Modeling  
The data pipeline is structured into layers:

- **Staging Layer:** cleaning and standardization  
- **Intermediate Layer:** transformation and enrichment  
- **Mart Layer:** KPI-ready tables  

**Rationale:**  
Improves maintainability, debugging, and logical separation of concerns.

---

### 2.4 Data Quality as a First-Class Concern  
Data validation is embedded using:
- dbt tests  
- explicit null handling  
- standardized value conversion  
- data trust metrics  

**Rationale:**  
Public-sector decisions require confidence in data reliability.

---

### 2.5 Incremental Complexity  
The system is built iteratively:

1. Raw ingestion  
2. Clean staging models  
3. Verified metrics  
4. Derived analytical models  
5. Automation  
6. Visualization  

**Rationale:**  
Prevents compounding errors and reduces debugging complexity.

---

## 3. Methodological Phases  

---

### Phase 1: Data Cleaning and Standardization  

**Objective:**  
Transform raw data into consistent, usable formats.

**Key Activities:**
- column renaming and normalization  
- handling missing values (`k. A.` → null)  
- parsing German numeric formats (e.g., "48 Mio.")  
- date standardization  
- harmonizing district and school-type labels  

**Output:**  
Clean staging tables with consistent schema.

---

### Phase 2: Metric Definition and Validation  

**Objective:**  
Define and validate all analytical metrics before downstream usage.

**Key Activities:**
- define KPIs (demand, supply, gap, risk, inclusion)  
- validate aggregation logic  
- ensure consistent grain across datasets  
- perform manual cross-checks on computed values  

**Output:**  
Trusted intermediate and mart models.

---

### Phase 3: Pipeline Automation  

**Objective:**  
Automate the full data workflow for reproducibility.

**Key Activities:**
- orchestrate ingestion and transformation using Airflow  
- integrate dbt runs and tests into pipeline  
- manage dependencies between tasks  
- implement failure handling and logging  

**Output:**  
Automated, repeatable data pipeline.

---

### Phase 4: Visualization and Decision Support  

**Objective:**  
Translate validated data into stakeholder-facing insights.

**Key Activities:**
- build dashboards in Metabase  
- implement filters (district, school type, time)  
- design decision-oriented visualizations  
- ensure traceability to underlying data models  

**Output:**  
Interactive dashboards for public-sector stakeholders.

---

### Phase 5: Presentation Optimization  

**Objective:**  
Prepare outputs for thesis evaluation and stakeholder communication.

**Key Activities:**
- refine dashboard clarity and labeling  
- simplify interpretation for non-technical users  
- create executive summaries and narratives  
- align outputs with policy-relevant questions  

**Output:**  
Presentation-ready artifacts and thesis documentation.

---

## 4. Analytical Techniques  

The project employs the following analytical methods:

### 4.1 Descriptive Analysis  
Summarizes:
- student demand  
- planned capacity  
- project characteristics  

---

### 4.2 Gap Analysis  
Compares:
- demand vs supply  
- district-level mismatches  
- school-type discrepancies  

---

### 4.3 Temporal Analysis  
Evaluates:
- capacity delivery timelines  
- delay exposure  
- planning horizons  

---

### 4.4 Risk Assessment  
Combines:
- delay factors  
- cost magnitude  
- interim dependency  
- demand pressure  

to generate project-level risk indicators.

---

### 4.5 Inclusion Analysis  
Focuses on:
- special-needs demand  
- special-needs capacity  
- district-level coverage gaps  

---

### 4.6 Data Quality Analysis  
Measures:
- completeness  
- consistency  
- validity  
- transformation success  

---

## 5. Technology Integration  

The methodology is implemented using the following tools:

- **DuckDB:** analytical database for fast local querying  
- **dbt:** transformation logic, testing, and modeling  
- **Python:** ingestion and auxiliary processing  
- **Airflow:** orchestration and automation  
- **Metabase:** visualization and dashboarding  
- **GitHub Codespaces:** development environment  

Each tool is used for a specific layer in the pipeline to maintain separation of concerns.

---

## 6. Validation Strategy  

Validation is performed at multiple levels:

### Data-Level Validation  
- raw vs staged row counts  
- null and missing value checks  
- format consistency checks  

### Model-Level Validation  
- dbt tests for constraints  
- cross-model consistency checks  
- aggregation verification  

### Output-Level Validation  
- dashboard vs model consistency  
- manual spot-checking of KPIs  
- logical sanity checks (e.g., no negative capacities)  

---

## 7. Assumptions and Limitations  

### Assumptions
- district-level aggregation is sufficient for analysis  
- planned infrastructure reflects intended delivery  
- school-type categories can be harmonized  

### Limitations
- no real-time data updates  
- limited spatial granularity  
- potential data quality issues in source datasets  
- no predictive modeling  

---

## 8. Methodological Justification  

This methodology is chosen to:

- reflect industry-standard analytics engineering practices  
- ensure reproducibility and auditability  
- prioritize correctness over speed  
- align with public-sector accountability requirements  
- support a defensible and rigorous thesis outcome  

---