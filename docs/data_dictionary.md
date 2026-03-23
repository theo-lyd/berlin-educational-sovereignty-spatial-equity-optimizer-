# Data Dictionary
## Data Audit and Source Understanding

This document defines the meaning, role, type, and cleaning requirements of the key columns in the two source workbooks.

---

## 1. Dataset: Student Demand (`od-eckdaten-allg-2024.xlsx`)

### Grain
One row represents a combination of:
- provider (`Traeger`)
- district (`Bezirk`)
- school type (`Schulart`)

### Columns

#### `Traeger`
- **Meaning:** the education provider or managing organization.
- **Key field:** no
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** the source column name contains a trailing space (`Traeger `) and should be trimmed.

#### `Bezirk`
- **Meaning:** Berlin district to which the student demand belongs.
- **Key field:** yes, as part of the natural grain
- **Type:** categorical / text
- **Needs cleaning:** minimal
- **Notes:** should be standardized against a controlled district vocabulary.

#### `Schulart`
- **Meaning:** school type or educational track.
- **Key field:** yes, as part of the natural grain
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** some school-type values contain composite labels; labels must be harmonized across datasets.

#### `Schüler (w/m/d)`
- **Meaning:** number of students.
- **Key field:** no, but it is the primary measure in this dataset.
- **Type:** numeric / integer
- **Needs cleaning:** no
- **Notes:** already structured as a numeric field.

---

## 2. Dataset: School Construction (`schulbaukarte-2025-.xlsx`)

### Grain
One row represents one school construction or infrastructure project.

### Columns

#### `Berliner Schulnummer`
- **Meaning:** official school number or project identifier.
- **Key field:** yes
- **Type:** identifier / text
- **Needs cleaning:** minimal
- **Notes:** should be treated as the primary project identifier.

#### `Schulname`
- **Meaning:** name of the school or project.
- **Key field:** no
- **Type:** text
- **Needs cleaning:** minimal
- **Notes:** useful for reporting and validation, not for joins.

#### `Bezirk`
- **Meaning:** Berlin district where the project is located.
- **Key field:** yes, for district-level analysis
- **Type:** categorical / text
- **Needs cleaning:** minimal
- **Notes:** should be standardized to match the demand dataset.

#### `Schulart`
- **Meaning:** school type associated with the project.
- **Key field:** yes, for school-type comparison
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** contains trailing-space variants and special categories such as `Drehscheibe` that must be modeled carefully.

#### `Baumaßnahme`
- **Meaning:** construction or intervention type.
- **Key field:** no
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** useful for classifying permanent vs temporary or modular interventions.

#### `Beschreibung`
- **Meaning:** free-text description of the project.
- **Key field:** no
- **Type:** text
- **Needs cleaning:** yes
- **Notes:** may contain useful contextual information, but should not be treated as structured data without parsing.

#### `Gebaute bzw. geplante Schulplätze`
- **Meaning:** number of built or planned school places.
- **Key field:** no
- **Type:** numeric or text depending on row
- **Needs cleaning:** yes
- **Notes:** contains at least one missing value and may require type conversion.

#### `Kapazität nach Baumaßnahme`
- **Meaning:** total capacity after the construction measure is completed.
- **Key field:** no
- **Type:** numeric or text depending on row
- **Needs cleaning:** yes
- **Notes:** contains `k. A.` values and must be standardized to numeric/null.

#### `Zügigkeit nach Baumaßnahme`
- **Meaning:** planned number of tracks/classes after construction.
- **Key field:** no
- **Type:** text / structured text
- **Needs cleaning:** yes
- **Notes:** may contain values such as `k. A.` or multi-line expressions like `1,5-zügig (Klasse 1-6)`; requires careful parsing.

#### `Nutzungsübergabe`
- **Meaning:** expected handover period for the completed project.
- **Key field:** no
- **Type:** text / planning period
- **Needs cleaning:** yes
- **Notes:** values are usually year ranges such as `2025/2026`, not exact dates.

#### `Gesamtkosten in Euro`
- **Meaning:** estimated total cost of the project.
- **Key field:** no
- **Type:** text / numeric string
- **Needs cleaning:** yes
- **Notes:** contains German-formatted strings such as `rund 27 Mio.` and should be converted to standardized Euro amounts.

#### `Adresse`
- **Meaning:** street address of the project.
- **Key field:** no
- **Type:** text
- **Needs cleaning:** minimal
- **Notes:** useful for spatial approximation and quality checks.

#### `PLZ`
- **Meaning:** postal code.
- **Key field:** no
- **Type:** numeric or text
- **Needs cleaning:** yes
- **Notes:** one missing value is present; should be stored as text to preserve leading zeros if needed.

#### `Ort`
- **Meaning:** locality / city.
- **Key field:** no
- **Type:** categorical / text
- **Needs cleaning:** minimal
- **Notes:** currently the only observed value is `Berlin`.

---

## 3. Shared Columns Across Both Datasets

### `Bezirk`
- **Meaning:** Berlin district.
- **Role:** shared analytical dimension.
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** must be standardized to the same spelling and casing across both datasets.

### `Schulart`
- **Meaning:** school type.
- **Role:** shared analytical dimension.
- **Type:** categorical / text
- **Needs cleaning:** yes
- **Notes:** harmonization is required because labels are not fully identical between the demand and construction datasets.

---

## 4. Cleaning Rules by Column Family

### 4.1 Identifier and categorical fields
Examples:
- `Traeger`
- `Bezirk`
- `Schulart`
- `Baumaßnahme`
- `Schulname`

**Cleaning actions:**
- trim whitespace
- standardize casing where appropriate
- harmonize category labels
- map known variants to canonical values

### 4.2 Numeric fields
Examples:
- `Schüler (w/m/d)`
- `Gebaute bzw. geplante Schulplätze`
- `Kapazität nach Baumaßnahme`
- `Gesamtkosten in Euro`

**Cleaning actions:**
- remove text qualifiers such as `rund`
- convert German decimal and thousand formats
- convert missing markers such as `k. A.` to null
- store in explicit numeric types after parsing

### 4.3 Planning-period fields
Examples:
- `Nutzungsübergabe`
- `Zügigkeit nach Baumaßnahme`

**Cleaning actions:**
- separate structured numeric content from descriptive text
- store the original value for traceability
- derive normalized fields where needed

### 4.4 Free-text fields
Examples:
- `Beschreibung`
- `Adresse`

**Cleaning actions:**
- trim whitespace
- preserve original value
- optionally derive tags or keywords later

---

## 5. Key-Field Summary

### Demand dataset key structure
The natural key is the combination of:
- `Traeger`
- `Bezirk`
- `Schulart`

### Construction dataset key structure
The most suitable project identifier is:
- `Berliner Schulnummer`

If needed, a composite key can be created using:
- `Berliner Schulnummer`
- `Schulname`
- `Bezirk`

---

## 6. Notes for Downstream Modeling

- Do not join the datasets on raw school-type labels without normalization.
- Treat temporary-site projects such as `Drehscheibe` separately from permanent school capacity projects.
- Preserve raw values in staging models before creating standardized fields.
- Keep original strings for auditability even after conversion to numeric or canonical forms.

