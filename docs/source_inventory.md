# Source Inventory
## Data Audit and Source Understanding

This document inventories the two source workbooks before any transformation logic is applied.

---

## 1. Source Workbooks

### 1.1 `od-eckdaten-allg-2024.xlsx`
**Purpose:** district-level student demand dataset.

- **Workbook sheets:** `Tabelle1`
- **Row count:** 116 data rows
- **Column count:** 4

### 1.2 `schulbaukarte-2025-.xlsx`
**Purpose:** school construction / infrastructure supply dataset.

- **Workbook sheets:** `Tabelle1`
- **Row count:** 511 data rows
- **Column count:** 14

---

## 2. Dataset 1 Inventory: Student Demand (`od-eckdaten-allg-2024.xlsx`)

### 2.1 Columns

| Column | Detected type | Role |
|---|---|---|
| `Traeger ` | text / categorical | provider category (public vs free-trägerschaft) |
| `Bezirk` | text / categorical | district identifier |
| `Schulart` | text / categorical | school type |
| `Schüler (w/m/d)` | integer | student count |

### 2.2 Missing values

- No missing values detected in any column.

### 2.3 Data-quality observations

- The column name `Traeger ` contains a trailing space and should be normalized.
- The file is highly structured and already numerically clean.
- The student count field is a true numeric integer field.

### 2.4 Distinct-value profile

- `Traeger `: 2 categories
- `Bezirk`: 12 districts
- `Schulart`: 7 school-type categories
- `Schüler (w/m/d)`: 115 distinct values

### 2.5 Important school-type labels found

- Grundschule
- Gymnasium
- Integrierte Sekundarschule; Gemeinschaftsschule
- Freie Waldorfschule
- Schule mit sonderpädagogischem Förderschwerpunkt „Geistige Entwicklung"
- Schule mit sonderpädagogischem Förderschwerpunkt „Lernen"
- Schule mit übrigen sonderpädagogischen Förderschwerpunkten

### 2.6 Interpretation

This workbook is the **demand-side baseline**. It is suitable for district-level aggregation, school-type segmentation, and inclusion-oriented analysis.

---

## 3. Dataset 2 Inventory: School Construction (`schulbaukarte-2025-.xlsx`)

### 3.1 Columns

| Column | Detected type | Role |
|---|---|---|
| `Berliner Schulnummer` | text / identifier | unique school/project identifier |
| `Schulname` | text | school or project name |
| `Bezirk` | text / categorical | district identifier |
| `Schulart` | text / categorical | school type |
| `Baumaßnahme` | text / categorical | construction measure type |
| `Beschreibung` | text | free-text project description |
| `Gebaute bzw. geplante Schulplätze` | mixed text / numeric | seat count or planning count |
| `Kapazität nach Baumaßnahme` | mixed text / numeric | post-project capacity |
| `Zügigkeit nach Baumaßnahme` | mixed text | track structure / class-level configuration |
| `Nutzungsübergabe` | text | planned handover year or year range |
| `Gesamtkosten in Euro` | mixed text | cost string with German formatting |
| `Adresse` | text | street address |
| `PLZ` | numeric / postal code | postal code |
| `Ort` | text | city name |

### 3.2 Missing values

Detected missing values:

- `Gebaute bzw. geplante Schulplätze`: 1 missing value
- `PLZ`: 1 missing value
- `Ort`: 1 missing value

All other columns are non-null.

### 3.3 Data-quality observations

This workbook is analytically useful but requires standardization before modeling.

#### a) Missing-value markers and placeholders

- `k. A.` appears in several fields and should be converted to nulls.
- Most important placeholder fields:
  - `Kapazität nach Baumaßnahme`
  - `Zügigkeit nach Baumaßnahme`
  - `Gebaute bzw. geplante Schulplätze`
  - `Gesamtkosten in Euro`

#### b) German numeric formatting

- Cost values are written as strings such as:
  - `rund 27 Mio.`
  - `rund 36 Mio.`
  - `rund 94 Mio.`
- These must be normalized to numeric values in Euro.

#### c) Mixed-format capacity/track fields

- `Kapazität nach Baumaßnahme` contains both numeric values and `k. A.`.
- `Zügigkeit nach Baumaßnahme` contains:
  - `k. A.`
  - numeric-like text with comma decimals, e.g. `1,5-zügig`
  - multi-line class-band descriptions
- This field should be normalized carefully and probably split into structured subfields.

#### d) Handover dates are ranges, not single dates

- `Nutzungsübergabe` uses ranges such as:
  - `2019/2020`
  - `2023/2024`
  - `2025/2026`
  - `2026/2027`
  - `2028/2029`
- This must be treated as a planning interval rather than a single date.

#### e) School-type normalization needed

Observed labels include:
- `Drehscheibe`
- `Gemeinschaftsschule`
- `Grundschule`
- `Gymnasium`
- `Integrierte Sekundarschule`
- `Integrierte Sekundarschule ` (with trailing space)
- `OSZ`
- `Schule mit sonderpädagogischem Förderschwerpunkt`

The trailing space in `Integrierte Sekundarschule ` should be removed.

### 3.4 Distinct-value profile

- `Berliner Schulnummer`: 474 distinct values
- `Schulname`: 472 distinct values
- `Bezirk`: 12 districts
- `Schulart`: 8 categories
- `Baumaßnahme`: 10 categories
- `Beschreibung`: 339 distinct values
- `Gebaute bzw. geplante Schulplätze`: 43 distinct values
- `Kapazität nach Baumaßnahme`: 75 distinct values
- `Zügigkeit nach Baumaßnahme`: 56 distinct values
- `Nutzungsübergabe`: 17 distinct values
- `Gesamtkosten in Euro`: 145 distinct values
- `Adresse`: 494 distinct values
- `PLZ`: 171 distinct values
- `Ort`: 1 distinct value (`Berlin`)

### 3.5 Important structural patterns

#### Construction measure types (`Baumaßnahme`)
Likely categories include:
- Temporäre Maßnahme
- Kombinationsmaßnahme
- Reaktivierung
- Neubau
- Sanierung
- Erweiterung / modularer Ergänzungsbau patterns

#### Temporary-site projects
Several rows reference `Drehscheibe` and `Temporäre Maßnahme`, which are important for interim-site risk analysis.

#### Spatial fields
- `Adresse` and `PLZ` are suitable for district-level spatial approximation.
- Exact travel-time analysis is not supported by the source data and would require external geospatial enrichment.

### 3.6 Examples of non-standard values

#### `Kapazität nach Baumaßnahme`
- `k. A.`

#### `Zügigkeit nach Baumaßnahme`
- `k. A.`
- `1,5-zügig (Klasse 1-6)`\n`4-zügig (Klasse 7-10)`\n`2-zügig (Klasse 11-13)`
- `2-zügig (Klasse 1-6)`\n`4-zügig (Klasse 7-10)`\n`1,5-zügig (Klasse 11-13)`

#### `Gesamtkosten in Euro`
- `rund 3 Mio.`
- `rund 25 Mio.`
- `rund 27 Mio.`
- `rund 36 Mio.`
- `rund 94 Mio.`

#### `Nutzungsübergabe`
- `2019/2020`
- `2023/2024`
- `2025/2026`
- `2026/2027`
- `2028/2029`

### 3.7 Interpretation

This workbook is the **supply-side pipeline**. It is rich enough for district-level planning, timing analysis, financial-risk analysis, and inclusion analysis, but it requires normalization before use in joins, measures, and dashboards.

---

## 4. Cross-Dataset Observations

### 4.1 Shared dimensions
Both datasets support comparison by:
- `Bezirk`
- `Schulart`

### 4.2 Key harmonization issues

- School-type labels are not fully standardized across the two files.
- The construction file includes a trailing-space variant in `Integrierte Sekundarschule `.
- The demand file includes combined school-type labels such as `Integrierte Sekundarschule; Gemeinschaftsschule`.
- The construction file includes `Drehscheibe`, which is a project type rather than a school type and should be modeled separately.

### 4.3 Analytical implication
The datasets can be linked, but only after:
- trimming whitespace
- standardizing school-type labels
- parsing numeric placeholders
- converting German-formatted strings into canonical values
- separating temporary-site projects from permanent school capacity projects

---

## 5. Recommended Next Step

Before transformation modeling, create a staging plan with:
- standardized column names
- type-casting rules
- null-handling rules
- parsing logic for cost, capacity, and handover fields
- controlled vocabulary for district and school-type values

