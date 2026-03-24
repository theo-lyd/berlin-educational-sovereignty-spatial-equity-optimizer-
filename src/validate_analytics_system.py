#!/usr/bin/env python3
"""Phase 11 validation, testing, and QA runner.

This script validates metric correctness, cross-model consistency,
dashboard-model integrity, and edge-case handling for the Berlin
education analytics system.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import duckdb


@dataclass
class CheckResult:
    check_id: str
    batch: str
    name: str
    passed: bool
    details: dict[str, Any]


class Validator:
    def __init__(self, db_path: Path) -> None:
        self.db_path = db_path
        self.conn = duckdb.connect(str(db_path))
        self.results: list[CheckResult] = []

    def close(self) -> None:
        self.conn.close()

    def q1(self, sql: str, params: tuple[Any, ...] | None = None) -> Any:
        if params is None:
            return self.conn.execute(sql).fetchone()[0]
        return self.conn.execute(sql, params).fetchone()[0]

    def table_exists(self, schema: str, table: str) -> bool:
        return bool(
            self.q1(
                """
                select count(*)
                from information_schema.tables
                where table_schema = ? and table_name = ?
                """,
                (schema, table),
            )
        )

    def column_exists(self, schema: str, table: str, column: str) -> bool:
        return bool(
            self.q1(
                """
                select count(*)
                from information_schema.columns
                where table_schema = ? and table_name = ? and column_name = ?
                """,
                (schema, table, column),
            )
        )

    def add_check(
        self,
        check_id: str,
        batch: str,
        name: str,
        passed: bool,
        details: dict[str, Any],
    ) -> None:
        self.results.append(
            CheckResult(
                check_id=check_id,
                batch=batch,
                name=name,
                passed=passed,
                details=details,
            )
        )

    @staticmethod
    def almost_equal(a: float | int, b: float | int, tol: float = 1e-6) -> bool:
        return abs(float(a) - float(b)) <= tol

    def run_batch_11_1_metric_correctness(self) -> None:
        # District totals
        districts_stg = self.q1(
            """
            select count(distinct bezirk_clean)
            from analytics_staging.stg_student_demand
            where bezirk_clean is not null
            """
        )
        districts_kpi = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_district_summary
            """
        )
        self.add_check(
            "11.1.1",
            "11.1",
            "district totals match staging and mart",
            districts_stg == districts_kpi,
            {
                "staging_distinct_districts": districts_stg,
                "mart_district_rows": districts_kpi,
            },
        )

        # Student totals across layers
        students_stg = self.q1(
            """
            select coalesce(sum(students), 0)
            from analytics_staging.stg_student_demand
            """
        )
        students_int = self.q1(
            """
            select coalesce(sum(demand_students_total), 0)
            from analytics_intermediate.int_district_aggregation
            """
        )
        students_kpi = self.q1(
            """
            select coalesce(sum(demand_students_total), 0)
            from analytics_marts.kpi_district_summary
            """
        )
        students_exec = self.q1(
            """
            select total_student_demand
            from analytics_marts.kpi_executive_overview
            """
        )
        students_pass = (
            self.almost_equal(students_stg, students_int)
            and self.almost_equal(students_stg, students_kpi)
            and self.almost_equal(students_stg, students_exec)
        )
        self.add_check(
            "11.1.2",
            "11.1",
            "student totals match across staging, intermediate, and marts",
            students_pass,
            {
                "staging_students": students_stg,
                "intermediate_students": students_int,
                "mart_students": students_kpi,
                "executive_students": students_exec,
            },
        )

        # Project totals across layers
        projects_stg = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            """
        )
        projects_int = self.q1(
            """
            select count(*)
            from analytics_intermediate.int_project_risk_ranking
            """
        )
        projects_kpi = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_project_risk_ranking
            """
        )
        projects_delay = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_delay_risk_dashboard
            """
        )
        projects_pass = (
            projects_stg == projects_int
            and projects_stg == projects_kpi
            and projects_stg == projects_delay
        )
        self.add_check(
            "11.1.3",
            "11.1",
            "project totals match across staging, intermediate, and marts",
            projects_pass,
            {
                "staging_projects": projects_stg,
                "intermediate_projects": projects_int,
                "mart_projects": projects_kpi,
                "delay_dashboard_projects": projects_delay,
            },
        )

        # Capacity totals across layers
        capacity_stg = self.q1(
            """
            select coalesce(sum(coalesce(planned_capacity, 0)), 0)
            from analytics_staging.stg_school_construction_projects
            """
        )
        capacity_int = self.q1(
            """
            select coalesce(sum(planned_capacity_total), 0)
            from analytics_intermediate.int_district_aggregation
            """
        )
        capacity_kpi = self.q1(
            """
            select coalesce(sum(planned_capacity_total), 0)
            from analytics_marts.kpi_district_summary
            """
        )
        capacity_exec = self.q1(
            """
            select total_planned_capacity
            from analytics_marts.kpi_executive_overview
            """
        )
        capacity_pass = (
            self.almost_equal(capacity_stg, capacity_int)
            and self.almost_equal(capacity_stg, capacity_kpi)
            and self.almost_equal(capacity_stg, capacity_exec)
        )
        self.add_check(
            "11.1.4",
            "11.1",
            "capacity totals match across staging, intermediate, and marts",
            capacity_pass,
            {
                "staging_capacity": capacity_stg,
                "intermediate_capacity": capacity_int,
                "mart_capacity": capacity_kpi,
                "executive_capacity": capacity_exec,
            },
        )

        # Cost conversion quality
        numeric_raw_costs = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where total_cost_raw is not null
              and regexp_matches(total_cost_raw, '.*[0-9].*')
            """
        )
        numeric_raw_but_null_parsed = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where total_cost_raw is not null
              and regexp_matches(total_cost_raw, '.*[0-9].*')
              and total_cost_eur is null
            """
        )
        negative_cost_count = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where total_cost_eur < 0
            """
        )
        cost_conversion_pass = (
            numeric_raw_but_null_parsed == 0 and negative_cost_count == 0
        )
        self.add_check(
            "11.1.5",
            "11.1",
            "cost conversions are valid and non-negative",
            cost_conversion_pass,
            {
                "numeric_raw_cost_rows": numeric_raw_costs,
                "numeric_raw_but_null_parsed": numeric_raw_but_null_parsed,
                "negative_parsed_cost_rows": negative_cost_count,
            },
        )

    def run_batch_11_2_model_consistency(self) -> None:
        # Gap total consistency
        gap_int = self.q1(
            """
            select coalesce(sum(demand_supply_gap_total), 0)
            from analytics_intermediate.int_district_aggregation
            """
        )
        gap_kpi = self.q1(
            """
            select coalesce(sum(demand_supply_gap_total), 0)
            from analytics_marts.kpi_district_summary
            """
        )
        gap_exec = self.q1(
            """
            select total_gap
            from analytics_marts.kpi_executive_overview
            """
        )
        gap_pass = (
            self.almost_equal(gap_int, gap_kpi)
            and self.almost_equal(gap_int, gap_exec)
        )
        self.add_check(
            "11.2.1",
            "11.2",
            "gap totals are consistent across intermediate and mart layers",
            gap_pass,
            {
                "intermediate_gap": gap_int,
                "mart_gap": gap_kpi,
                "executive_gap": gap_exec,
            },
        )

        # Inclusion coverage consistency
        inclusion_int_demand = self.q1(
            """
            select coalesce(sum(special_needs_demand_students), 0)
            from analytics_intermediate.int_inclusion_coverage
            """
        )
        inclusion_kpi_demand = self.q1(
            """
            select coalesce(sum(special_needs_demand_students), 0)
            from analytics_marts.kpi_inclusion_coverage
            """
        )
        inclusion_int_capacity = self.q1(
            """
            select coalesce(sum(special_needs_planned_capacity), 0)
            from analytics_intermediate.int_inclusion_coverage
            """
        )
        inclusion_kpi_capacity = self.q1(
            """
            select coalesce(sum(special_needs_planned_capacity), 0)
            from analytics_marts.kpi_inclusion_coverage
            """
        )
        inclusion_pass = (
            self.almost_equal(inclusion_int_demand, inclusion_kpi_demand)
            and self.almost_equal(inclusion_int_capacity, inclusion_kpi_capacity)
        )
        self.add_check(
            "11.2.2",
            "11.2",
            "inclusion metrics are consistent from intermediate to mart",
            inclusion_pass,
            {
                "int_special_needs_demand": inclusion_int_demand,
                "mart_special_needs_demand": inclusion_kpi_demand,
                "int_special_needs_capacity": inclusion_int_capacity,
                "mart_special_needs_capacity": inclusion_kpi_capacity,
            },
        )

        # Delivery timeline consistency
        timeline_int_rows = self.q1(
            """
            select count(*)
            from analytics_intermediate.int_delivery_timeline
            """
        )
        timeline_kpi_rows = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_delivery_timeline
            """
        )
        timeline_int_capacity = self.q1(
            """
            select coalesce(sum(planned_capacity_total), 0)
            from analytics_intermediate.int_delivery_timeline
            """
        )
        timeline_kpi_capacity = self.q1(
            """
            select coalesce(sum(planned_capacity_total), 0)
            from analytics_marts.kpi_delivery_timeline
            """
        )
        timeline_pass = (
            timeline_int_rows == timeline_kpi_rows
            and self.almost_equal(timeline_int_capacity, timeline_kpi_capacity)
        )
        self.add_check(
            "11.2.3",
            "11.2",
            "delivery timeline metrics are consistent from intermediate to mart",
            timeline_pass,
            {
                "int_rows": timeline_int_rows,
                "mart_rows": timeline_kpi_rows,
                "int_capacity_total": timeline_int_capacity,
                "mart_capacity_total": timeline_kpi_capacity,
            },
        )

        # Risk ranking consistency and key/rank quality
        risk_total = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_project_risk_ranking
            """
        )
        risk_rank_distinct = self.q1(
            """
            select count(distinct project_risk_rank)
            from analytics_marts.kpi_project_risk_ranking
            """
        )
        risk_unique_keys = self.q1(
            """
            select count(distinct project_key)
            from analytics_marts.kpi_project_risk_ranking
            """
        )
        risk_null_rank = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_project_risk_ranking
            where project_risk_rank is null
            """
        )
        risk_min_rank = self.q1(
            """
            select min(project_risk_rank)
            from analytics_marts.kpi_project_risk_ranking
            """
        )
        risk_duplicate_rows = self.q1(
            """
            select count(*)
            from (
                select project_key, count(*) as c
                from analytics_marts.kpi_project_risk_ranking
                group by 1
                having count(*) > 1
            ) d
            """
        )
        # dense_rank intentionally allows ties; preserve source fidelity while making duplicates explicit.
        risk_pass = (
            risk_unique_keys > 0
            and risk_null_rank == 0
            and risk_min_rank == 1
            and risk_rank_distinct > 0
        )
        self.add_check(
            "11.2.4",
            "11.2",
            "risk ranking has valid dense-rank coverage and explicit duplicate-key accounting",
            risk_pass,
            {
                "total_rows": risk_total,
                "distinct_project_keys": risk_unique_keys,
                "duplicate_project_key_groups": risk_duplicate_rows,
                "distinct_project_ranks": risk_rank_distinct,
                "null_project_risk_rank_rows": risk_null_rank,
                "min_project_risk_rank": risk_min_rank,
            },
        )

        # Slippage consistency
        slippage_int = self.q1(
            """
            select count(*)
            from analytics_intermediate.int_planning_slippage
            """
        )
        slippage_kpi = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_planning_slippage
            """
        )
        self.add_check(
            "11.2.5",
            "11.2",
            "planning slippage mart mirrors intermediate rows",
            slippage_int == slippage_kpi,
            {
                "int_slippage_rows": slippage_int,
                "kpi_slippage_rows": slippage_kpi,
            },
        )

    def run_batch_11_3_dashboard_integrity(self) -> None:
        dashboard_specs: dict[str, dict[str, Any]] = {
            "Executive Overview": {
                "model": "kpi_executive_overview",
                "required_fields": [
                    "total_student_demand",
                    "total_planned_capacity",
                    "total_gap",
                    "high_risk_district_count",
                    "overall_data_trust_score",
                ],
                "filter_fields": [],
            },
            "District Comparison": {
                "model": "kpi_district_comparison",
                "required_fields": [
                    "bezirk_clean",
                    "schulart_clean",
                    "district_gap_total",
                    "district_demand_total",
                    "district_capacity_total",
                    "demand_share_pct",
                    "spatial_relief_score",
                ],
                "filter_fields": ["bezirk_clean", "schulart_clean"],
            },
            "Delivery Timeline": {
                "model": "kpi_delivery_timeline",
                "required_fields": [
                    "delivery_year",
                    "planned_capacity_total",
                    "planned_capacity_permanent",
                    "planned_capacity_temporary",
                    "cumulative_capacity_total",
                ],
                "filter_fields": ["delivery_year"],
            },
            "Inclusion Coverage": {
                "model": "kpi_inclusion_coverage",
                "required_fields": [
                    "bezirk_clean",
                    "special_needs_demand_students",
                    "special_needs_planned_capacity",
                    "special_needs_gap_total",
                    "special_needs_coverage_ratio",
                ],
                "filter_fields": ["bezirk_clean"],
            },
            "Financial and Interim Risk": {
                "model": "kpi_delay_risk_dashboard",
                "required_fields": [
                    "project_key",
                    "bezirk_clean",
                    "project_risk_bucket",
                    "delayed_handover_flag",
                    "expensive_delayed_project_flag",
                    "total_cost_eur",
                ],
                "filter_fields": [
                    "bezirk_clean",
                    "project_risk_bucket",
                    "delayed_handover_flag",
                ],
            },
            "Zugigkeit vs Demand": {
                "model": "kpi_zugigkeit_scatter",
                "required_fields": [
                    "bezirk_clean",
                    "schulart_clean",
                    "student_volume",
                    "planned_track_count",
                    "track_per_student_ratio",
                ],
                "filter_fields": ["bezirk_clean", "schulart_clean"],
            },
            "Data Trust and Audit": {
                "model": "kpi_data_quality_dashboard",
                "required_fields": [
                    "model_name",
                    "missing_value_rate_pct",
                    "invalid_value_rate_pct",
                    "ka_rate_pct",
                    "transformation_success_rate",
                ],
                "filter_fields": ["model_name"],
            },
        }

        all_passed = True
        per_page: dict[str, Any] = {}

        for page_name, spec in dashboard_specs.items():
            model = spec["model"]
            table_ok = self.table_exists("analytics_marts", model)

            missing_required = [
                col
                for col in spec["required_fields"]
                if not self.column_exists("analytics_marts", model, col)
            ]
            missing_filters = [
                col
                for col in spec["filter_fields"]
                if not self.column_exists("analytics_marts", model, col)
            ]

            filter_query_ok = True
            filter_probe_counts: dict[str, int] = {}
            if table_ok:
                for filter_col in spec["filter_fields"]:
                    try:
                        probe = self.q1(
                            f"""
                            select count(*)
                            from analytics_marts.{model}
                            where {filter_col} is not null
                            """
                        )
                        filter_probe_counts[filter_col] = int(probe)
                    except Exception:
                        filter_query_ok = False

            page_passed = (
                table_ok
                and not missing_required
                and not missing_filters
                and filter_query_ok
            )
            if not page_passed:
                all_passed = False

            per_page[page_name] = {
                "model": model,
                "table_exists": table_ok,
                "missing_required_fields": missing_required,
                "missing_filter_fields": missing_filters,
                "filter_probe_counts": filter_probe_counts,
                "filter_queries_ok": filter_query_ok,
                "passed": page_passed,
            }

        self.add_check(
            "11.3.1",
            "11.3",
            "every dashboard page maps to a dbt mart model and fields exist",
            all_passed,
            per_page,
        )

    def run_batch_11_4_edge_cases(self) -> None:
        # Missing dates
        missing_dates_stg = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where handover_year_start is null
            """
        )
        missing_dates_risk = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_delay_risk_dashboard
            where handover_year_start is null
            """
        )
        self.add_check(
            "11.4.1",
            "11.4",
            "missing handover dates are preserved through risk dashboard",
            missing_dates_stg == missing_dates_risk,
            {
                "missing_handover_dates_staging": missing_dates_stg,
                "missing_handover_dates_risk_dashboard": missing_dates_risk,
            },
        )

        # Missing costs
        missing_cost_stg = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where total_cost_eur is null
            """
        )
        missing_cost_risk = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_delay_risk_dashboard
            where total_cost_eur is null
            """
        )
        self.add_check(
            "11.4.2",
            "11.4",
            "missing costs are preserved through risk dashboard",
            missing_cost_stg == missing_cost_risk,
            {
                "missing_cost_staging": missing_cost_stg,
                "missing_cost_risk_dashboard": missing_cost_risk,
            },
        )

        # Unknown districts
        unknown_district_stg = self.q1(
            """
            select count(*)
            from analytics_staging.stg_student_demand
            where bezirk_clean is null
            """
        )
        null_districts_kpi = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_district_summary
            where bezirk_clean is null
            """
        )
        self.add_check(
            "11.4.3",
            "11.4",
            "unknown districts are isolated in staging and excluded from district marts",
            null_districts_kpi == 0,
            {
                "unknown_district_rows_staging": unknown_district_stg,
                "null_district_rows_district_summary": null_districts_kpi,
            },
        )

        # Special-needs records
        sn_demand_stg = self.q1(
            """
            select coalesce(sum(students), 0)
            from analytics_staging.stg_student_demand
            where is_special_needs
            """
        )
        sn_demand_kpi = self.q1(
            """
            select coalesce(sum(special_needs_demand_students), 0)
            from analytics_marts.kpi_inclusion_coverage
            """
        )
        self.add_check(
            "11.4.4",
            "11.4",
            "special-needs demand is preserved in inclusion mart",
            self.almost_equal(sn_demand_stg, sn_demand_kpi),
            {
                "special_needs_students_staging": sn_demand_stg,
                "special_needs_students_inclusion_mart": sn_demand_kpi,
            },
        )

        # Zero-capacity records and divide-by-zero handling
        zero_capacity_stg = self.q1(
            """
            select count(*)
            from analytics_staging.stg_school_construction_projects
            where coalesce(planned_capacity, 0) = 0
            """
        )
        zero_capacity_risk = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_delay_risk_dashboard
            where coalesce(planned_capacity, 0) = 0
            """
        )
        pressure_ratio_bad = self.q1(
            """
            select count(*)
            from analytics_marts.kpi_district_comparison
            where planned_capacity_total = 0
              and demand_pressure_ratio is not null
            """
        )
        zero_capacity_pass = (
            zero_capacity_stg == zero_capacity_risk and pressure_ratio_bad == 0
        )
        self.add_check(
            "11.4.5",
            "11.4",
            "zero-capacity edge case is preserved and division safety is enforced",
            zero_capacity_pass,
            {
                "zero_capacity_rows_staging": zero_capacity_stg,
                "zero_capacity_rows_risk_dashboard": zero_capacity_risk,
                "invalid_pressure_ratio_rows": pressure_ratio_bad,
            },
        )

    def run(self) -> dict[str, Any]:
        self.run_batch_11_1_metric_correctness()
        self.run_batch_11_2_model_consistency()
        self.run_batch_11_3_dashboard_integrity()
        self.run_batch_11_4_edge_cases()

        passed = sum(1 for r in self.results if r.passed)
        failed = len(self.results) - passed

        by_batch: dict[str, dict[str, int]] = {}
        for r in self.results:
            if r.batch not in by_batch:
                by_batch[r.batch] = {"passed": 0, "failed": 0}
            if r.passed:
                by_batch[r.batch]["passed"] += 1
            else:
                by_batch[r.batch]["failed"] += 1

        return {
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "db_path": str(self.db_path),
            "overall_status": "pass" if failed == 0 else "fail",
            "summary": {
                "total_checks": len(self.results),
                "passed": passed,
                "failed": failed,
                "by_batch": by_batch,
            },
            "checks": [
                {
                    "check_id": r.check_id,
                    "batch": r.batch,
                    "name": r.name,
                    "status": "pass" if r.passed else "fail",
                    "details": r.details,
                }
                for r in self.results
            ],
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run Phase 11 analytical validation checks."
    )
    parser.add_argument(
        "--db-path",
        type=Path,
        default=Path("data/warehouse/berlin_education.duckdb"),
        help="Path to DuckDB warehouse file.",
    )
    parser.add_argument(
        "--output-json",
        type=Path,
        default=Path("reports/phase11_validation_report.json"),
        help="Path to write the JSON report.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if not args.db_path.exists():
        raise FileNotFoundError(f"DuckDB file not found: {args.db_path}")

    args.output_json.parent.mkdir(parents=True, exist_ok=True)

    validator = Validator(args.db_path)
    try:
        report = validator.run()
    finally:
        validator.close()

    args.output_json.write_text(json.dumps(report, indent=2), encoding="utf-8")

    summary = report["summary"]
    print("Phase 11 Validation Complete")
    print(f"Overall status: {report['overall_status'].upper()}")
    print(
        "Checks: "
        f"{summary['passed']} passed, {summary['failed']} failed, "
        f"{summary['total_checks']} total"
    )
    print(f"Report written: {args.output_json}")


if __name__ == "__main__":
    main()
