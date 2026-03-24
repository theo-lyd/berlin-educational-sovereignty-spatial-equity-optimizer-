# dbt Project Initialization Scaffold

This scaffold sets up the dbt project so the raw DuckDB tables can be referenced as sources, transformed into staging models, and validated with dbt tests.

---

## 1. Recommended dbt Folder Structure

```text
 dbt/
 ├── dbt_project.yml
 ├── profiles.yml
 ├── macros/
 │   ├── parse_euro.sql
 │   ├── parse_integer.sql
 │   ├── normalize_text.sql
 │   └── safe_trim.sql
 ├── models/
 │   ├── sources/
 │   │   ├── demand_sources.yml
 │   │   └── construction_sources.yml
 │   ├── staging/
 │   │   ├── stg_student_demand.sql
 │   │   ├── stg_student_demand.yml
 │   │   ├── stg_school_construction_projects.sql
 │   │   └── stg_school_construction_projects.yml
 │   ├── intermediate/
 │   └── marts/
 └── snapshots/
```

---

## 2. `dbt/dbt_project.yml`

```yaml
name: berlin_educational_sovereignty
version: '1.0.0'
config-version: 2
profile: berlin_educational_sovereignty

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
snapshot-paths: ["snapshots"]
macro-paths: ["macros"]
clean-targets:
  - "target"
  - "dbt_packages"

models:
  berlin_educational_sovereignty:
    staging:
      +materialized: view
      +schema: staging
    intermediate:
      +materialized: view
      +schema: intermediate
    marts:
      +materialized: table
      +schema: marts

snapshots:
  berlin_educational_sovereignty:
    +target_schema: snapshots
```

---

## 3. `dbt/profiles.yml`

This profile assumes the DuckDB database file is stored inside the repo at `data/warehouse/berlin_education.duckdb`.

```yaml
berlin_educational_sovereignty:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ../data/warehouse/berlin_education.duckdb
      threads: 4
      schema: analytics
      extensions:
        - httpfs
        - parquet
```

---

## 4. Source Definitions

The raw ingestion layer created DuckDB tables in schema `raw`.

The expected raw table names are:
- `raw.raw__od_eckdaten_allg_2024__tabelle1`
- `raw.raw__schulbaukarte_2025__tabelle1`

### 4.1 `dbt/models/sources/demand_sources.yml`

```yaml
version: 2

sources:
  - name: raw_demand
    database: main
    schema: raw
    tables:
      - name: raw__od_eckdaten_allg_2024__tabelle1
        description: Raw student demand workbook loaded into DuckDB.
```

### 4.2 `dbt/models/sources/construction_sources.yml`

```yaml
version: 2

sources:
  - name: raw_construction
    database: main
    schema: raw
    tables:
      - name: raw__schulbaukarte_2025__tabelle1
        description: Raw school construction workbook loaded into DuckDB.
```

---

## 5. Staging Models

The staging layer performs non-destructive standardization only.

### 5.1 `dbt/models/staging/stg_student_demand.sql`

```sql
{{ config(materialized='view') }}

with source as (
    select *
    from {{ source('raw_demand', 'raw__od_eckdaten_allg_2024__tabelle1') }}
)

select
    trim("Traeger") as traeger,
    trim("Bezirk") as bezirk,
    trim("Schulart") as schulart,
    cast("Schüler (w/m/d)" as integer) as students
from source
```

### 5.2 `dbt/models/staging/stg_school_construction_projects.sql`

```sql
{{ config(materialized='view') }}

with source as (
    select *
    from {{ source('raw_construction', 'raw__schulbaukarte_2025__tabelle1') }}
)

select
    trim("Berliner Schulnummer") as berlin_school_number,
    trim("Schulname") as school_name,
    trim("Bezirk") as bezirk,
    trim("Schulart") as schulart,
    trim("Baumaßnahme") as baumassnahme,
    trim("Beschreibung") as beschreibung,
    nullif(trim(cast("Gebaute bzw. geplante Schulplätze" as varchar)), '') as built_or_planned_places_raw,
    nullif(trim(cast("Kapazität nach Baumaßnahme" as varchar)), '') as capacity_after_measure_raw,
    nullif(trim(cast("Zügigkeit nach Baumaßnahme" as varchar)), '') as track_structure_raw,
    nullif(trim(cast("Nutzungsübergabe" as varchar)), '') as handover_period_raw,
    nullif(trim(cast("Gesamtkosten in Euro" as varchar)), '') as total_cost_raw,
    trim("Adresse") as adresse,
    cast("PLZ" as varchar) as plz,
    trim("Ort") as ort
from source
```

---

## 6. First dbt Tests

### 6.1 `dbt/models/staging/stg_student_demand.yml`

```yaml
version: 2

models:
  - name: stg_student_demand
    description: Cleaned student demand staging model.
    columns:
      - name: traeger
        tests:
          - not_null
      - name: bezirk
        tests:
          - not_null
      - name: schulart
        tests:
          - not_null
      - name: students
        tests:
          - not_null
```

### 6.2 `dbt/models/staging/stg_school_construction_projects.yml`

```yaml
version: 2

models:
  - name: stg_school_construction_projects
    description: Cleaned school construction staging model.
    columns:
      - name: berlin_school_number
        tests:
          - not_null
      - name: bezirk
        tests:
          - not_null
      - name: schulart
        tests:
          - not_null
      - name: school_name
        tests:
          - not_null
```

---

## 7. Recommended Macros (to add in the next chunk)

The staging SQL above intentionally keeps parsing minimal so the raw values stay traceable. The next step is to add reusable macros for:
- German cost parsing
- integer parsing with `k. A.` handling
- safe trimming
- text normalization

Those macros should be introduced before building the final mart models.

---

## 8. Validation Order

1. Confirm dbt can connect to the DuckDB file.
2. Confirm the two raw sources resolve.
3. Run the staging models.
4. Run the dbt tests.
5. Only then build the intermediate and mart layers.

---

## 9. Notes

- This scaffold assumes the raw ingestion step already created the raw DuckDB schema.
- The source names must match the table names created during ingestion.
- If the raw table names change, update the source YAML files accordingly.

