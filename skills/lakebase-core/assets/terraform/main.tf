# Lakebase project, branch, and compute. Replace every <PLACEHOLDER>.
# Argument names come from the Databricks Terraform provider docs (GA), last verified 2026-11-20:
#   https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_project.md
#   https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_branch.md
#   https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_endpoint.md
# Constraints: autoscaling max - min <= 16 CU; scale-to-zero only <= 32 CU; HA needs no_suspension = true.

resource "databricks_postgres_project" "this" {
  project_id = "<PROJECT_ID>"
  spec = {
    pg_version   = <PG_VERSION>        # 16, 17, 18 or 19 (product default 18)
    display_name = "<DISPLAY_NAME>"
    # budget_policy_id       = "<BUDGET_POLICY_ID>"
    # enable_pg_native_login = true    # password login is off by default for new projects
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Adopt the implicit root branch created with the project.
resource "databricks_postgres_branch" "production" {
  branch_id        = "production"
  parent           = databricks_postgres_project.this.name
  spec = {
    no_expiry = true
  }
  replace_existing = true
}

# Adopt the implicit read-write compute on that branch.
resource "databricks_postgres_endpoint" "primary" {
  endpoint_id      = "<ENDPOINT_ID>"
  parent           = databricks_postgres_branch.production.name
  spec = {
    endpoint_type            = "ENDPOINT_TYPE_READ_WRITE"
    autoscaling_limit_min_cu = <MIN_CU>
    autoscaling_limit_max_cu = <MAX_CU>
    suspend_timeout_duration = "<SECONDS>s"   # or: no_suspension = true
  }
  replace_existing = true
}

# Optional read replica.
resource "databricks_postgres_endpoint" "read_replica" {
  endpoint_id = "<REPLICA_ENDPOINT_ID>"
  parent      = databricks_postgres_branch.production.name
  spec = {
    endpoint_type            = "ENDPOINT_TYPE_READ_ONLY"
    autoscaling_limit_min_cu = <MIN_CU>
    autoscaling_limit_max_cu = <MAX_CU>
  }
}
