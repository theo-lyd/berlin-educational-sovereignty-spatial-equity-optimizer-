# Raw Load Validation Report

Generated at (UTC): 2026-03-24T08:15:39.180175+00:00

## Summary
- Sheets processed: 2
- Successful loads: 2
- Failed loads: 0
- Row-count mismatches: 0

## Per-sheet results
| Source File | Sheet | Table | Expected Rows | Loaded Rows | Columns | Status |
|---|---|---:|---:|---:|---:|---|
| od-eckdaten-allg-2024.xlsx | Tabelle1 | `raw.raw__od_eckdaten_allg_2024__tabelle1` | 116 | 116 | 4 | success |
| schulbaukarte-2025-.xlsx | Tabelle1 | `raw.raw__schulbaukarte_2025__tabelle1` | 511 | 511 | 14 | success |

## Interpretation
The raw layer is considered valid when each workbook sheet is loaded without destructive cleaning and row counts match the source workbook expectation.