#!/usr/bin/env bash
# Databricks CLI commands for Lakebase. Replace every <PLACEHOLDER>.
# Syntax comes from these pages, last verified 2026-11-20:
#   https://docs.databricks.com/aws/en/oltp/projects/manage-projects
#   https://docs.databricks.com/aws/en/oltp/projects/manage-branches
#   https://docs.databricks.com/aws/en/oltp/projects/manage-computes
#   https://docs.databricks.com/aws/en/oltp/projects/authentication
#   https://docs.databricks.com/aws/en/oltp/projects/manage-roles
#   https://docs.databricks.com/aws/en/dev-tools/cli/reference/postgres-commands
# This is a reference sheet, not a script to run end to end.
set -euo pipefail

# Project
databricks postgres create-project <PROJECT_ID> --json '{"spec": {"display_name": "<DISPLAY_NAME>", "pg_version": <PG_VERSION>}}'

# Branch that expires after 7 days (for a permanent branch, use "no_expiry": true)
databricks postgres create-branch projects/<PROJECT_ID> <BRANCH_ID> \
  --json '{"spec": {"source_branch": "projects/<PROJECT_ID>/branches/production", "ttl": "604800s"}}'

# Scale-to-zero timeout
databricks postgres update-endpoint projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID> spec.suspension \
  --json '{"spec": {"suspend_timeout_duration": "300s"}}'

# Turn on native password login (off by default for new projects)
databricks postgres update-project projects/<PROJECT_ID> spec.enable_pg_native_login \
  --json '{"spec": {"enable_pg_native_login": true}}'

# OAuth role for a workspace user
databricks postgres create-role projects/<PROJECT_ID>/branches/<BRANCH_ID> --role-id <ROLE_ID> \
  --json '{"spec": {"identity_type": "USER", "postgres_role": "<USER_EMAIL>"}}'

# OAuth token (valid for 1 hour)
databricks postgres generate-database-credential projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID> --output json

# Synced table (needs CLI 0.298 or later)
databricks postgres create-synced-table <CATALOG>.<SCHEMA>.<TABLE> --json '{"spec": {"source_table_full_name": "<SRC_CATALOG>.<SRC_SCHEMA>.<SRC_TABLE>", "branch": "projects/<PROJECT_ID>/branches/<BRANCH_ID>", "primary_key_columns": ["<PK_COLUMN>"], "scheduling_policy": "SNAPSHOT", "postgres_database": "<DATABASE>", "create_database_objects_if_missing": true}}'

# Soft-delete, recover, purge
databricks postgres delete-project projects/<PROJECT_ID>
databricks postgres list-projects --show-deleted
databricks postgres undelete-project projects/<PROJECT_ID>
databricks postgres delete-project projects/<PROJECT_ID> --purge
