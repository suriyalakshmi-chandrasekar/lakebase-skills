# Concepts: project, branch, compute, endpoint, database, roles

Last verified: 2026-11-20. Check `release-watch.md` before relying on any of this.

## What Lakebase is

- "Lakebase is a fully managed Postgres database integrated into the Databricks platform." The product page is titled **Lakebase Postgres**.
  Source: https://docs.databricks.com/aws/en/oltp/ and https://learn.microsoft.com/en-us/azure/databricks/oltp/
- Scope note: this skill covers only the Databricks product. It does not cover migrating data into Lakebase from other systems. For that, use the `lakebase-migration` skill.

## Object model (in the docs' own terms)

Source for this section: https://docs.databricks.com/aws/en/oltp/projects/manage-projects and https://docs.databricks.com/aws/en/oltp/projects/core-concepts

| Object | Definition from the docs |
|---|---|
| **Project** | "the top-level container for your Lakebase resources, including branches, computes, databases, and roles." |
| **Branch** | "Data resides in branches." Every project is created with a root branch named `production`, which "cannot be deleted." |
| **Compute** | "a virtualized computing resource that includes vCPU and memory for running Postgres." Each branch has a "single primary R/W compute". Read replicas are read-only computes. |
| **Endpoint** | "the stable connection point your application uses to reach a database." |
| **Database** | "A database is a container for SQL objects such as schemas, tables, views, functions, and indexes." The default database is `databricks_postgres`. |
| **Role** | "Roles are Postgres roles. A role is required to create and access a database. A role belongs to a branch." |

Resource names used by the API, CLI, and SDKs:
- `projects/{project-id}`
- `projects/{project-id}/branches/{branch-id}`
- `projects/{project-id}/branches/{branch-id}/endpoints/{endpoint-id}`

Source: https://docs.databricks.com/aws/en/oltp/projects/authentication and https://docs.databricks.com/api/postgres/v1/endpoint

How branches relate to each other:
- Branches are copy-on-write. They "share the underlying storage through pointers to the same data." Every branch except a root branch has a parent.
- Source: https://docs.databricks.com/aws/en/oltp/projects/branches

## Supported Postgres versions

- Supported major versions: 16, 17, 18, and 19. **Postgres 18 is the default.**
- Source: https://docs.databricks.com/aws/en/oltp/projects/compatibility and https://docs.databricks.com/aws/en/oltp/projects/postgres-version-support
- Details: `postgres-compatibility.md`

## Availability

Each cloud's docs list regions separately. Each table below was read from that cloud's own docs.

"Your Lakebase project is created in your Databricks workspace region." The region "cannot be modified."

| Cloud | Regions (from docs) | Source |
|---|---|---|
| AWS (12) | us-east-1, us-east-2, us-west-2, ca-central-1, sa-east-1, eu-central-1, eu-west-1, eu-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1 | https://docs.databricks.com/aws/en/oltp/projects/manage-projects |
| Azure (24) | eastus, eastus2, centralus, northcentralus, southcentralus, westus, westus2, westcentralus, canadacentral, brazilsouth, northeurope, uksouth, westeurope, francecentral, germanywestcentral, swedencentral, uaenorth, southafricanorth, australiaeast, centralindia, southeastasia, eastasia, japaneast, koreacentral | https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/manage-projects |
| GCP (5) | us-east4, us-central1, us-west1, europe-west3, asia-southeast1 | https://docs.databricks.com/gcp/en/oltp/projects/manage-projects |

General availability dates differ by cloud, per each cloud's release notes:

| Cloud | GA date |
|---|---|
| AWS | 2026-01-22 |
| Azure | 2026-03-02 (after Beta on 2026-02-04) |
| GCP | 2026-10-30 (after Beta on 2026-06-15) |

Sources: https://docs.databricks.com/aws/en/release-notes/lakebase/, https://learn.microsoft.com/en-us/azure/databricks/release-notes/lakebase/, https://docs.databricks.com/gcp/en/release-notes/lakebase/

Project permission levels:
- The three levels are **CAN CREATE**, **CAN USE**, and **CAN MANAGE**.
- By default, workspace users get CAN CREATE. The project owner and workspace admins get CAN MANAGE.
- Source: https://docs.databricks.com/aws/en/oltp/projects/manage-project-permissions
- See `auth-and-roles.md`.

For compliance profiles, see `networking-security.md`.

> UNVERIFIED: workspace prerequisites (tier, serverless enablement) and any user entitlement needed to create a project. No Lakebase page stating these was found. Check the Get started page: https://docs.databricks.com/aws/en/oltp/projects/get-started

## Legacy: Lakebase Provisioned and the upgrade to Autoscaling

Source for this section: https://docs.databricks.com/aws/en/oltp/instances/ and https://docs.databricks.com/aws/en/oltp/upgrade-to-autoscaling

What Provisioned was:
- "Lakebase Provisioned was the original version of Lakebase. It used fixed-size provisioned compute that you scaled manually."
- All instances "have been upgraded to the Lakebase Autoscaling platform, now known simply as Lakebase."

Timeline:
- "Since March 12, 2026, new Lakebase instances are now created as Autoscaling projects."
- The upgrade page says: "The upgrade of Lakebase Provisioned instances to Autoscaling completed in July 2026."
- The upgrade was automatic. "Connections restart briefly."

What changed for upgraded instances:
- Scale-to-zero is not enabled by default on upgraded instances.
- Existing global connection strings keep working. New regional hostnames are also available.
- "Lakebase GA pricing applies after the upgrade."

Compute mapping from Provisioned capacity to Autoscaling:

| Provisioned capacity | Autoscaling range |
|---|---|
| 1 | 4–8 CU |
| 2 | 8–16 CU |
| 4 | 16–32 CU |
| 8 | 48–64 CU |

Updating infrastructure-as-code:
- Bundles: https://docs.databricks.com/aws/en/oltp/update-to-autoscaling-dabs. Needs Databricks CLI 1.2.0 or higher. You deploy twice, with `databricks bundle deployment bind`/`unbind` in between. The guide converts `database_instances` to `postgres_projects` / `postgres_branches` / `postgres_endpoints` (+ `postgres_catalogs`, `postgres_synced_tables`).
- Terraform: https://docs.databricks.com/aws/en/oltp/update-to-autoscaling-terraform. Needs Terraform 1.7 or higher. You apply twice. The first apply uses `import` blocks and `replace_existing = true`. The second uses `removed { ... lifecycle { destroy = false } }` blocks. The guide converts `databricks_database_instance` to `databricks_postgres_project` / `_branch` / `_endpoint` / `_catalog` / `_synced_table`.
- In the billing system table, `billing_origin_product` = `DATABASE` means Provisioned instances. `LAKEBASE` means the current version. Source: https://docs.databricks.com/aws/en/admin/system-tables/billing

> CONFLICT (same docs site, two different dates):
> - The DABs guide says "Starting June 2026, Databricks automatically upgrades existing Provisioned instances". The Terraform guide says the same.
> - The upgrade page says the upgrade "completed in July 2026".
> Report both dates if asked.
