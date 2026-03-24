"""Phase 4 — Raw DuckDB verification.

This script inspects the raw DuckDB layer created by ingest_raw_duckdb.py and
verifies that the row counts and table structure match expectations before
moving on to staging.

It:
- lists all raw tables under the raw schema
- prints each table's row count and columns
- checks the ingestion log table
- optionally compares raw table counts against the JSON validation report

Usage:
    python src/validate_raw_duckdb.py \
        --db-path data/warehouse/berlin_education.duckdb \
        --report-json reports/raw_load_validation_report.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List

import duckdb


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Verify raw DuckDB tables and validation reports.")
    parser.add_argument(
        "--db-path",
        type=Path,
        default=Path("data/warehouse/berlin_education.duckdb"),
        help="Path to the DuckDB database file.",
    )
    parser.add_argument(
        "--report-json",
        type=Path,
        default=Path("reports/raw_load_validation_report.json"),
        help="Path to the JSON validation report written during ingestion.",
    )
    return parser.parse_args()


def fetch_raw_tables(con: duckdb.DuckDBPyConnection) -> List[str]:
    rows = con.execute(
        """
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw'
        ORDER BY table_name
        """
    ).fetchall()
    return [f"{schema}.{table_name}" for schema, table_name in rows]


def table_row_count(con: duckdb.DuckDBPyConnection, table_name: str) -> int:
    return con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]


def table_columns(con: duckdb.DuckDBPyConnection, table_name: str) -> List[Dict[str, Any]]:
    rows = con.execute(f"PRAGMA table_info('{table_name}')").fetchall()
    return [
        {
            "cid": row[0],
            "name": row[1],
            "type": row[2],
            "notnull": row[3],
            "dflt_value": row[4],
            "pk": row[5],
        }
        for row in rows
    ]


def load_validation_report(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        return []
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    args = parse_args()

    if not args.db_path.exists():
        print(f"DuckDB database not found: {args.db_path}", file=sys.stderr)
        return 1

    con = duckdb.connect(str(args.db_path), read_only=True)

    try:
        raw_tables = fetch_raw_tables(con)
        if not raw_tables:
            print("No raw tables found in schema 'raw'.")
            return 1

        print("Raw table inventory")
        print("=" * 80)
        for table_name in raw_tables:
            row_count = table_row_count(con, table_name)
            cols = table_columns(con, table_name)
            print(f"\nTable: {table_name}")
            print(f"Rows: {row_count}")
            print(f"Columns: {len(cols)}")
            for col in cols:
                print(f"  - {col['name']} ({col['type']})")

        print("\nIngestion log check")
        print("=" * 80)
        try:
            log_count = con.execute("SELECT COUNT(*) FROM raw.raw_ingestion_log").fetchone()[0]
            print(f"raw.raw_ingestion_log rows: {log_count}")
        except Exception as exc:  # noqa: BLE001
            print(f"Could not read raw.raw_ingestion_log: {exc}")

        report_rows = load_validation_report(args.report_json)
        if report_rows:
            print("\nValidation report comparison")
            print("=" * 80)
            report_map = {row["table_name"]: row for row in report_rows}
            mismatches = []
            for table_name in raw_tables:
                short_name = table_name
                reported = report_map.get(short_name)
                actual_rows = table_row_count(con, table_name)
                if reported is None:
                    print(f"Missing report entry for {short_name}")
                    mismatches.append(short_name)
                    continue
                expected_rows = reported.get("expected_rows")
                loaded_rows = reported.get("loaded_rows")
                status = reported.get("status")
                print(
                    f"{short_name}: report expected={expected_rows}, report loaded={loaded_rows}, actual={actual_rows}, status={status}"
                )
                if status != "success" or actual_rows != loaded_rows:
                    mismatches.append(short_name)

            if mismatches:
                print("\nVerification failed for:")
                for item in mismatches:
                    print(f"- {item}")
                return 1

            print("\nVerification passed: row counts match the validation report.")
        else:
            print("\nNo JSON validation report found; inspected tables only.")
            print("Generate the ingestion report first if you want count comparison.")

        return 0
    finally:
        con.close()


if __name__ == "__main__":
    raise SystemExit(main())
