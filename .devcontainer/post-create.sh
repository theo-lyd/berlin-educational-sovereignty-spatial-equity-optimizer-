#!/usr/bin/env bash
set -euo pipefail

echo "Setting up project Python environment..."
python -m venv .venv
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install -r requirements.txt

echo "Setting up Airflow isolated environment..."
python -m venv .airflow-venv
./.airflow-venv/bin/python -m pip install --upgrade pip
./.airflow-venv/bin/python -m pip install apache-airflow

echo "Creating Airflow project structure..."
mkdir -p airflow/dags airflow/logs airflow/plugins

echo "Persisting environment variables..."
cat <<EOF >> ~/.bashrc

# Airflow project-scoped config
export AIRFLOW_HOME=\$(pwd)/airflow
export AIRFLOW__CORE__LOAD_EXAMPLES=False
EOF

echo "Environment setup complete."