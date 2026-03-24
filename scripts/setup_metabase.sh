#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METABASE_DIR="$ROOT_DIR/.metabase"
PLUGINS_DIR="$METABASE_DIR/plugins"
METABASE_JAR="$METABASE_DIR/metabase.jar"
METABASE_VERSION="v0.49.21"
METABASE_JAR_URL="https://downloads.metabase.com/${METABASE_VERSION}/metabase.jar"
DUCKDB_DRIVER_URL="https://github.com/motherduckdb/metabase_duckdb_driver/releases/download/1.4.4.0/duckdb.metabase-driver.jar"

mkdir -p "$PLUGINS_DIR" "$ROOT_DIR/.metabase-data"

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: Java is not installed. Install Java 17+ and rerun this script."
  exit 1
fi

if [ ! -f "$METABASE_JAR" ]; then
  echo "Downloading Metabase ${METABASE_VERSION} ..."
  curl -fL "$METABASE_JAR_URL" -o "$METABASE_JAR"
else
  echo "Metabase jar already exists at $METABASE_JAR"
fi

if [ ! -f "$PLUGINS_DIR/duckdb.metabase-driver.jar" ]; then
  echo "Downloading DuckDB Metabase driver ..."
  curl -fL "$DUCKDB_DRIVER_URL" -o "$PLUGINS_DIR/duckdb.metabase-driver.jar"
else
  echo "DuckDB driver already exists at $PLUGINS_DIR/duckdb.metabase-driver.jar"
fi

echo "Setup complete."
echo "Next: ./scripts/run_metabase.sh"
