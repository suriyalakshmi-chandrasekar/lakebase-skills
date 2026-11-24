# Unity Catalog integration

Last verified: 2026-11-20. Check `release-watch.md` first.

Sources:
- AWS: https://docs.databricks.com/aws/en/oltp/projects/register-uc
- Azure: https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/register-uc. No differences from AWS were found.

## What registration does

"Registering a Lakebase database in Unity Catalog creates a read-only catalog that represents your Postgres database."

The catalog is read-only. "To modify data, use the Lakebase SQL Editor or connect directly to your database."

## Prerequisites

- A Lakebase project with at least one database.
- `CREATE CATALOG` on the metastore.
- Serverless compute: a serverless SQL warehouse, or serverless notebooks and jobs.

Pro or classic SQL warehouses and classic compute are not supported. Using them fails with `PERMISSION_DENIED` (`UC_LAKEBASE_CATALOG_ACCESS_DENIED`).

## Register

**UI:**
1. Use the app switcher to go to **Analytics and AI**.
2. In Catalog Explorer, choose **+** → **Create a catalog**.
3. Enter a name.
4. For the type, choose **Lakebase Postgres**, then **Autoscaling**.
5. Pick the project, branch, and database.
6. Click **Create**.

**REST:**

```
POST https://<WORKSPACE_HOST>/api/2.0/postgres/catalogs?catalog_id=<CATALOG_NAME>
{"spec": {"postgres_database": "<DATABASE>", "branch": "projects/<PROJECT_ID>/branches/<BRANCH_ID>"}}
```

This is a long-running operation. Poll it until `done: true`.

**Other ways to register:**
- SDK: `w.postgres.create_catalog(...)`. To delete, use `w.postgres.delete_catalog("catalogs/<CATALOG_NAME>")`.
- Terraform: the `databricks_postgres_catalog` resource, with `spec = { postgres_database, create_database_if_missing, branch }`. Source: https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_synced_table.md
- Bundles: `postgres_catalogs` (Beta, CLI 1.0.0+).

## Query from Databricks SQL

```sql
SELECT * FROM <CATALOG>.public.<TABLE> WHERE created_at >= current_date - INTERVAL 7 DAYS;
```

You can join these tables with lakehouse tables in the same query.

## Governance

- "The user who registers the database becomes the catalog owner."
- Grant access with standard Unity Catalog grants, for example ``GRANT USE CATALOG ON CATALOG <CATALOG> TO `<GROUP>`;`` and ``GRANT SELECT ON CATALOG <CATALOG> TO `<GROUP>`;``.
- "Direct connections to your Lakebase database use Postgres roles and permissions independently." See `auth-and-roles.md`.

## Limitations (page headings)

- **Read-only access.**
- **Serverless compute required.**
- **Single database per catalog.**
- **Metadata sync.** Unity Catalog caches metadata, so new objects may not appear right away. Use **Refresh Schema** to update it.
- **Branched database registration not supported.** A branch inherits the registration metadata of its parent, so registering the branch fails.

Unregistering removes the catalog but leaves the database untouched. If the catalog has synced tables, delete them first.
