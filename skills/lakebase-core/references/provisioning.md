# Provisioning projects, branches, and computes

Last verified: 2026-11-20. Check `release-watch.md` before stating any limit or status. Templates are in `assets/`.

## Compute sizing

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-computes and https://docs.databricks.com/aws/en/oltp/projects/autoscaling

Memory:
- "Each Compute Unit (CU) allocates approximately 2 GB of RAM."

Sizes:
- Autoscaling sizes are 0.5 CU, then whole numbers from 1 to 64 CU. Autoscaling is "available for computes up to 64 CU (128 GB)".
- Fixed-size computes go up to 112 CU.

Autoscaling range:
- "The difference between your maximum and minimum cannot exceed 16 CU (that is, `max - min ≤ 16 CU`)."
- Example: 8–24 CU is allowed. 0.5–32 CU is not.

Scale-to-zero eligibility:
- Scale-to-zero is available only for computes of 32 CU or smaller.
- It is not available with high availability.

> CONFLICT: manage-computes gives fixed sizes as "65 to 112" in one place and "80, 96, or 112" in its table.

> CONFLICT: the default `production` compute is shown two ways on https://docs.databricks.com/aws/en/oltp/projects/manage-projects. The table says "8 - 16 CU". The "Compute defaults" section says "2 ↔ 4 CU".

## Scale to zero

Source: https://docs.databricks.com/aws/en/oltp/projects/scale-to-zero and https://docs.databricks.com/api/postgres/v1/endpoint

- Default: "The inactivity timeout defaults to 24 hours and can be set between 60 seconds and 7 days."
- API field for the timeout: `suspend_timeout_duration`, for example `"300s"`.
- To disable scale-to-zero, set `no_suspension: true` and include `spec.suspension` in the update mask.
- `no_suspension: false` is invalid and returns an error.
- `spec.disabled: true` is a different setting. It blocks all connections.

## Creating resources

### UI

In the Lakebase App, create a project. It gets a `production` branch, a primary compute, and the `databricks_postgres` database.

Source: https://docs.databricks.com/aws/en/oltp/projects/get-started

### CLI

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects, https://docs.databricks.com/aws/en/oltp/projects/manage-branches, https://docs.databricks.com/aws/en/oltp/projects/manage-computes

```bash
# Project (the project ID is positional)
databricks postgres create-project <PROJECT_ID> --json '{"spec": {"display_name": "<DISPLAY_NAME>", "pg_version": <PG_VERSION>, "budget_policy_id": "<POLICY_ID>"}}'

# Branch that expires after 7 days
databricks postgres create-branch projects/<PROJECT_ID> <BRANCH_ID> --json '{"spec": {"source_branch": "projects/<PROJECT_ID>/branches/production", "ttl": "604800s"}}'
# For a permanent branch, use "no_expiry": true instead of "ttl"

# Scale-to-zero timeout
databricks postgres update-endpoint projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID> spec.suspension --json '{"spec": {"suspend_timeout_duration": "300s"}}'

# Inspect a compute
databricks postgres get-endpoint projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID> --output json
```

To change the CU range, update the mask `"spec.autoscaling_limit_min_cu,spec.autoscaling_limit_max_cu"` with `update-endpoint`.

> UNVERIFIED: no documented usage example for `databricks postgres create-endpoint` was found. The command exists in https://docs.databricks.com/aws/en/dev-tools/cli/commands.

### REST

Source: https://docs.databricks.com/api/postgres/v1/postgres

Base path: `/api/2.0/postgres`. The API reference labels these operations GA.

| Resource | Endpoints |
|---|---|
| Projects | `GET/POST /projects` (POST needs `?project_id=`)<br>`GET/PATCH/DELETE /projects/{id}`<br>`POST /projects/{id}/undelete` |
| Branches | `GET/POST /projects/{id}/branches` (`?branch_id=`)<br>`GET/PATCH/DELETE /projects/{id}/branches/{b}` |
| Endpoints | `GET/POST .../branches/{b}/endpoints` (`?endpoint_id=`)<br>`GET/PATCH/DELETE .../endpoints/{e}` |
| Databases | `GET/POST .../branches/{b}/databases` (`?database_id=`; body needs `spec.role` and `spec.postgres_database`) |
| Roles | `GET/POST .../branches/{b}/roles` (`?role_id=`)<br>DELETE accepts `reassign_owned_to` |
| Operations | `GET /projects/{id}/operations/{op}` |
| Credentials | `POST /credentials` |

Other details:
- PATCH requires `update_mask`.
- On project list, delete, and undelete, the API reference marks `show_deleted`, `purge`, and undelete as **Beta**.
- Create and update calls are long-running operations. The response contains an operation `name` with `done: false`. Poll the operation until `done: true`. The SDK's `.wait()` blocks until then.
- Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects

### Python SDK

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects and https://databricks-sdk-py.readthedocs.io/en/latest/workspace/postgres/postgres.html

```python
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.postgres import Project, ProjectSpec, Branch, BranchSpec, Duration

w = WorkspaceClient()
w.postgres.create_project(
    project=Project(spec=ProjectSpec(display_name="<DISPLAY_NAME>", pg_version=<PG_VERSION>)),
    project_id="<PROJECT_ID>",
).wait()

w.postgres.create_branch(
    parent="projects/<PROJECT_ID>",
    branch=Branch(spec=BranchSpec(ttl=Duration(seconds=604800),
                                  source_branch="projects/<PROJECT_ID>/branches/production")),
    branch_id="<BRANCH_ID>",
).wait()
```

Other SDK signatures:
- `create_endpoint(parent, endpoint, endpoint_id)`
- `update_endpoint(name, endpoint, update_mask)`
- `create_database(parent, database, database_id=None)`
- `create_role(parent, role, role_id=None)`

### Terraform

Source: https://github.com/databricks/terraform-provider-databricks/tree/main/docs/resources

All of these resources carry a **GA** badge in the provider docs:
- `databricks_postgres_project`
- `databricks_postgres_branch`
- `databricks_postgres_endpoint`
- `databricks_postgres_synced_table`

Each also references `databricks_postgres_catalog`, `databricks_postgres_database`, and `databricks_postgres_role`.

Key arguments:

| Resource | Arguments |
|---|---|
| `databricks_postgres_project` | `project_id`<br>`spec = { pg_version, display_name, history_retention_duration, budget_policy_id, custom_tags, enable_pg_native_login, default_endpoint_settings = { autoscaling_limit_min_cu, autoscaling_limit_max_cu, suspend_timeout_duration, no_suspension } }` |
| `databricks_postgres_branch` | `branch_id`<br>`parent` (`projects/{id}`)<br>`spec = { no_expiry \| ttl \| expire_time, is_protected, source_branch, source_snapshot, ... }`<br>`replace_existing` |
| `databricks_postgres_endpoint` | `endpoint_id`<br>`parent`<br>`spec = { endpoint_type = "ENDPOINT_TYPE_READ_WRITE" \| "ENDPOINT_TYPE_READ_ONLY", autoscaling_limit_min_cu, autoscaling_limit_max_cu, suspend_timeout_duration \| no_suspension, disabled, group = { min, max, enable_readable_secondaries } }` |

Notes on these resources:
- Use `replace_existing = true` to adopt the implicit `production` branch or the read-write endpoint.
- Read current values from `status`, not `spec`.
- High availability needs `no_suspension = true`.

Template: `assets/terraform/main.tf`.

### Bundles

The tool is now called **Declarative Automation Bundles** ("formerly known as Databricks Asset Bundles").
Source: https://docs.databricks.com/aws/en/dev-tools/bundles/

Resource keys and the CLI version that added them:

| Key | Added in CLI |
|---|---|
| `postgres_projects` | 0.287.0 |
| `postgres_branches` | 0.287.0 |
| `postgres_endpoints` | 0.287.0 |
| `postgres_catalogs` | 1.0.0 |
| `postgres_synced_tables` | 1.0.0 |
| `postgres_databases` | 1.4.0 |
| `postgres_roles` | 1.4.0 |
| `postgres_snapshot_schedules` | 1.16.0 |

- Each of these sections is labelled **Beta** on https://docs.databricks.com/aws/en/dev-tools/bundles/resources.
- Template: `assets/bundles/databricks.yml`. It is built from the documented field names. Check it against the resources page before use.

> CONFLICT: the bundles reference gives `pg_version` as "16 or 17", but the product supports 16–19 with 18 as the default. The Terraform provider default for `pg_version` is 17.

> CONFLICT: the bundles resources are labelled Beta, but the matching REST API and Terraform resources are labelled GA.

## Project settings worth knowing

- History window (restore window): 2–30 days in the UI, default 7. See `branching-and-recovery.md`.
- Budget policy and custom tags: see `billing-model.md`.
- Password login (`spec.enable_pg_native_login`): see `auth-and-roles.md`.
- Update window: see `observability-operations.md`.

> CONFLICT: the project API doc gives `history_retention_duration` as 172800s–3024000s (2–35 days). The UI says 2–30 days. The bundles reference says 0s–2592000s. Source: https://docs.databricks.com/api/postgres/v1/project
