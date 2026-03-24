# Phase 12 Defense Slides

## Slide 1 - Title

Berlin Educational Sovereignty and Spatial Equity Optimizer

Subtitle:
An analytics engineering system for district-level education capacity planning.

Presenter notes:
- One sentence on motivation.
- One sentence on what was built end-to-end.

## Slide 2 - The Problem

Key points:
- demand growth is uneven across districts
- construction delivery timing does not always match demand timing
- inclusion obligations require targeted special-needs provision
- temporary solutions can create financial inefficiency if prolonged

Presenter notes:
- emphasize policy risk when data is fragmented.

## Slide 3 - Pipeline Overview

Visual:
Raw Excel -> DuckDB raw -> dbt staging -> dbt intermediate -> dbt marts -> Metabase

Key points:
- reproducible, version-controlled transformation flow
- no manual spreadsheet edits in analytical path
- QA gates before dashboard consumption

## Slide 4 - Data Model Architecture

Visual:
Layered model with schemas:
- raw
- analytics_staging
- analytics_intermediate
- analytics_marts
- analytics_snapshots

Key points:
- separation of concerns
- easier auditing and debugging
- supports historical slippage tracking

## Slide 5 - KPI Framework

Show five KPI groups:
- demand
- supply
- equity
- risk
- data quality

Call out examples:
- district gap score
- delay exposure
- inclusion coverage rate
- spatial relief score
- data trust score

## Slide 6 - Dashboard Structure

Show seven pages:
- executive overview
- district comparison
- delivery timeline
- inclusion coverage
- financial and interim risk
- zugigkeit vs demand
- data trust and audit

Presenter notes:
- explain drill-down path from citywide to project-level detail.

## Slide 7 - Main Findings (Current Data Snapshot)

Reference values from validated marts:
- total student demand: 404019
- total planned capacity: 71900
- total gap: 332119
- special-needs demand: 9027
- special-needs planned capacity: 1516

Interpretation:
- large structural gap remains
- inclusion undercoverage is material
- timeline and risk prioritization are required

## Slide 8 - Quality and Validation

Show Phase 11 QA summary:
- 16 checks passed
- 0 failed
- checks cover metric correctness, consistency, dashboard integrity, edge cases

Show how missing values and unknowns are handled explicitly.

## Slide 9 - Business and Public-Sector Value

Value statement:
- better prioritization of district investments
- earlier visibility into delivery risk
- clearer inclusion compliance monitoring
- improved transparency of planning assumptions

## Slide 10 - Limitations and Next Steps

Limitations:
- limited source scope
- planning data is not guarantee data
- district-level granularity
- descriptive system, not causal model

Next steps:
- richer geospatial granularity
- scenario simulation
- budget optimization extensions

## Slide 11 - Conclusion

Close with one sentence:
This project provides a reproducible and decision-oriented analytics foundation for Berlin education planning under uncertainty.

## Slide 12 - Q and A

Prompt:
Questions on architecture, KPI logic, validation, and policy relevance.
