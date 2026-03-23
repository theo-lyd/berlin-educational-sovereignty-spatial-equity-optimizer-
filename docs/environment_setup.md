# Environment Setup
## Codespaces Configuration

## Purpose

This document describes how to make the repository usable inside GitHub Codespaces for:

- Python
- DuckDB
- dbt
- Airflow
- Metabase access
- SQL-based development

---

## Recommended Setup Strategy

Use both:

1. a `.devcontainer/` configuration for the Codespaces environment
2. a `requirements.txt` file for Python dependencies

This makes the environment reproducible and easier to defend during the thesis review.

---

## Why the `.devcontainer/` folder matters

The Codespace is created from a development container.  
That means the repository itself should define the environment, not only the local package list.

The `.devcontainer/` folder should contain:

- `devcontainer.json`
- `post-create.sh`

This is the project’s environment recipe.

---

## Why `requirements.txt` still matters

`requirements.txt` is the source of truth for Python libraries used in the project, including:

- DuckDB Python client
- pandas
- dbt DuckDB adapter
- dotenv support
- SQL utilities

It does not replace the dev container. It complements it.

---

## First-time setup steps

1. Open the repository in GitHub Codespaces.
2. Wait for the dev container to build.
3. Let the post-create script install the Python dependencies.
4. Verify the environment with these commands:

```bash
python --version
git --version
dbt --version
airflow version