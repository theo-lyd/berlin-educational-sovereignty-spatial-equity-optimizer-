# Environment Setup

## Purpose

This document defines a reproducible development environment for:

- Python (data processing)
- DuckDB (warehouse)
- dbt (transformations)
- Airflow 3 (orchestration)
- Metabase (visualization)

The setup is designed for GitHub Codespaces and ensures portability and thesis reproducibility.

---

## Architecture Overview

We use **two isolated Python environments**:

### 1. Project Environment (`.venv`)
Used for:
- DuckDB
- pandas
- dbt
- general Python code

### 2. Airflow Environment (`.airflow-venv`)
Used exclusively for:
- Apache Airflow 3

This separation avoids dependency conflicts (Airflow has strict constraints).

---

## Dev Container Configuration

The `.devcontainer/` folder defines the Codespaces environment:

- `devcontainer.json` → container definition
- `post-create.sh` → automated setup

The post-create script:
- creates both virtual environments
- installs dependencies
- prepares Airflow directory structure
- configures environment variables

---

## Environment Variables

Airflow requires **project-scoped configuration**.

This must always be set before running Airflow:

```bash
export AIRFLOW_HOME=$(pwd)/airflow
export AIRFLOW__CORE__LOAD_EXAMPLES=False