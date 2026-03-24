#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METABASE_DIR="$ROOT_DIR/.metabase"
METABASE_JAR="$METABASE_DIR/metabase.jar"
PLUGINS_DIR="$METABASE_DIR/plugins"

if [ ! -f "$METABASE_JAR" ]; then
  echo "Metabase jar not found. Run ./scripts/setup_metabase.sh first."
  exit 1
fi

if [ ! -f "$PLUGINS_DIR/duckdb.metabase-driver.jar" ]; then
  echo "DuckDB Metabase driver not found. Run ./scripts/setup_metabase.sh first."
  exit 1
fi

export MB_PLUGINS_DIR="$PLUGINS_DIR"
export MB_DB_FILE="$ROOT_DIR/.metabase-data/metabase.db"
export MB_JETTY_PORT="3000"

cd "$METABASE_DIR"
exec java --add-opens java.base/java.nio=ALL-UNNAMED -jar "$METABASE_JAR"
