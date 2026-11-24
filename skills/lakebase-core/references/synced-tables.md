# Synced tables (Delta / Unity Catalog → Lakebase)

Last verified: 2026-11-20. Check `release-watch.md` first.

Main source: https://docs.databricks.com/aws/en/oltp/projects/sync-tables. Other sources are cited inline.

## Status

- "LTAP Direct Writes is in Beta. Synced tables are generally available."
- The REST Get, Create, and Delete operations are labelled GA. Source: https://docs.databricks.com/api/postgres/v1/synced-table

> CONFLICT: the bundles resource `postgres_synced_tables` is labelled Beta (https://docs.databricks.com/aws/en/dev-tools/bundles/resources). The Terraform resource `databricks_postgres_synced_table` is labelled GA.

## Sources and result

Supported source types:
- "Managed and external Delta tables"
- "Managed and external Iceberg tables"
- "Views and materialized views"

The synced table appears in Postgres as a read-only table. Sync pipelines are "managed Lakeflow pipelines".

## Sync modes

| Mode | Docs description | Guidance from docs |
|---|---|---|
| Snapshot | "One-time copy of all data" | "10x more efficient if modifying >10% of source data". The source only needs to support `SELECT *`. |
| Triggered | "Scheduled updates that run on demand or at intervals". Inserts, updates, and deletes are propagated on each refresh. | "Expensive if run <5min intervals" |
| Continuous | "Real-time streaming with seconds of latency" | "Lowest lag, highest cost. Minimum 15-second intervals" |

How each mode runs:
- **Snapshot and Triggered** run only when started. You can click **Sync now**, or use a Lakeflow Job with a "Database Table Sync pipeline" task.
- **Continuous** runs as a stream.

The API enum for the mode is `scheduling_policy`, with the values `SNAPSHOT`, `TRIGGERED`, and `CONTINUOUS`.

## Change Data Feed requirement

Triggered and Continuous modes "must provide a change data feed". There are two ways to provide one.

**Write-time CDF** (legacy). Enable it with:

```sql
ALTER TABLE <CATALOG>.<SCHEMA>.<TABLE> SET TBLPROPERTIES (delta.enableChangeDataFeed = true)
```

**Automatic CDF.** It "Computes row-level changes at query time rather than at write time, using row tracking".
- Requires Databricks Runtime 19 or above.
- Works on managed Delta tables with row tracking, Iceberg v3 tables, or external Delta tables with row tracking.
- Not supported on tables that have row filters or column masks.
- Source: https://docs.databricks.com/aws/en/tables/features/change-data-feed

## Keys and nulls

Primary key:
- `primary_key_columns` is required. "At least one column must be specified."

Duplicate key values:
- If primary key values can repeat, clear **Unique** in the UI and set a **Timeseries Key**.
- The synced table then keeps only the row with the latest timeseries value for each key.
- If keys repeat and no timeseries key is set, "the sync pipeline fails".

Nulls:
- "Columns in the primary key are not nullable in the synced table. Rows with nulls in primary key columns are excluded from the sync."

The primary key and timeseries key can't be changed after the table is created.

## Schema changes

- "Only additive schema changes (like adding columns) are supported for Triggered and Continuous modes."
- "Updating a synced table's definition in place isn't supported through any interface". To make any other change, delete the synced table and create it again.

> UNVERIFIED: how Snapshot mode handles schema changes. The docs don't say.

## Type mapping

| Delta / UC | Postgres |
|---|---|
| BIGINT | BIGINT |
| BINARY | BYTEA |
| BOOLEAN | BOOLEAN |
| DATE | DATE |
| DECIMAL(p,s) | NUMERIC |
| DOUBLE | DOUBLE PRECISION |
| FLOAT | REAL |
| INT | INTEGER |
| INTERVAL | INTERVAL |
| SMALLINT | SMALLINT |
| STRING | TEXT |
| TIMESTAMP | TIMESTAMP WITH TIME ZONE |
| TIMESTAMP_NTZ | TIMESTAMP WITHOUT TIME ZONE |
| TINYINT | SMALLINT |
| ARRAY, MAP, STRUCT, VARIANT | JSONB |

Unsupported types: "GEOGRAPHY, GEOMETRY, and OBJECT types are not supported."

Type overrides (`type_overrides`):
- `ARRAY<FLOAT|DOUBLE>` → `vector(n)` (`PG_SPECIFIC_TYPE_VECTOR`, where n is 1–16,000), or `halfvec(n)` (`PG_SPECIFIC_TYPE_HALFVEC`). Install a vector extension first.
- `STRING` → `varchar(n)` (`PG_SPECIFIC_TYPE_VARCHAR`, where n is 1–10,485,760).

Null bytes (0x00) in STRING, ARRAY, MAP, or STRUCT values make the sync fail. See `troubleshooting.md`.

## LTAP Direct Writes (Beta)

Sources: https://docs.databricks.com/aws/en/oltp/projects/sync-tables and https://docs.databricks.com/aws/en/oltp/projects/ltap-overview

What it is:
- It is "an optional synced table setting that speeds up large loads". "It's off by default".
- It "writes data directly into the storage layer backing your Lakebase branch instead of routing the bulk write through the live compute endpoint".

What it speeds up:
- All modes: the initial load.
- Snapshot mode: every later sync too.

Requirements:
- Postgres 16, 17, or 18.
- A workspace admin may need to enable the "LTAP Direct Writes" preview.
- It can be set only when you create the table.

Indexes:
- Only B-tree indexes stay on the direct-write path.
- Other index types, such as GIN, fall back to the standard path.

In Terraform, the spec field is `accelerated_sync`.

The release notes list LTAP Direct Writes only for AWS (2026-08-25).

## Capacity

- Connections: each synced table uses up to 16 connections. They count toward the compute's connection limit.
- Tables per source: up to 20 synced tables per source table.
- Size: synced data counts toward the branch's storage quota. Databricks recommends "not exceeding 1 TB for tables requiring refreshes".
- Full refresh: during a full refresh, the old copy and the new copy both count toward the quota.

Write rates:

| Mode | Rate |
|---|---|
| Continuous and Triggered | "approximately 150 rows per second per Capacity Unit (CU)" |
| Snapshot | "up to 2,000 rows per second per CU" |

Names: database, schema, and table names may only contain `[A-Za-z0-9_]+`.

Indexes:
- Every full load rebuilds indexes.
- Use `CREATE INDEX`, not `CONCURRENTLY`.
- If an index build takes more than 20 minutes while a sync waits, the sync fails.

## Monitoring

UI:
- The **Overview** tab shows sync status, configuration, pipeline status, and the last sync time.

SDK:
- Call `w.postgres.get_synced_table("synced_tables/<CATALOG>.<SCHEMA>.<TABLE>")`.
- Read `status.detailed_state`, `status.last_sync_time`, and `status.message`.

`detailed_state` values:
- `SYNCED_TABLE_PROVISIONING`
- `SYNCED_TABLE_PROVISIONING_INITIAL_SNAPSHOT`
- `SYNCED_TABLE_PROVISIONING_PIPELINE_RESOURCES`
- `SYNCED_TABLE_ONLINE`
- `SYNCED_TABLE_ONLINE_CONTINUOUS_UPDATE`
- `SYNCED_TABLE_ONLINE_TRIGGERED_UPDATE`
- `SYNCED_TABLE_ONLINE_NO_PENDING_UPDATE`
- `SYNCED_TABLE_ONLINE_PIPELINE_FAILED`
- `SYNCED_TABLE_ONLINE_UPDATING_PIPELINE_RESOURCES`
- `SYNCED_TABLE_OFFLINE`
- `SYNCED_TABLE_OFFLINE_FAILED`

"A large sync can report INITIALIZING for the full run. This is expected and does not mean the pipeline is stuck."

Lineage: query `system.access.table_lineage` with `entity_type = PIPELINE`.

## Syntax

### CLI

The synced-table commands need CLI 0.298 or later. Source: https://docs.databricks.com/aws/en/dev-tools/cli/reference/postgres-commands

```bash
databricks postgres create-synced-table <CATALOG>.<SCHEMA>.<TABLE> --json '{"spec": {"source_table_full_name": "<SRC_CATALOG>.<SRC_SCHEMA>.<SRC_TABLE>", "branch": "projects/<PROJECT_ID>/branches/<BRANCH_ID>", "primary_key_columns": ["<PK_COLUMN>"], "scheduling_policy": "SNAPSHOT", "postgres_database": "<DATABASE>", "create_database_objects_if_missing": true}}'
databricks postgres get-synced-table "synced_tables/<CATALOG>.<SCHEMA>.<TABLE>"
databricks postgres delete-synced-table "synced_tables/<CATALOG>.<SCHEMA>.<TABLE>"
```

### REST

Source: https://docs.databricks.com/api/postgres/v1/synced-table

- `POST /api/2.0/postgres/synced_tables?synced_table_id=<CATALOG>.<SCHEMA>.<TABLE>`. This is a long-running operation.
- `GET /api/2.0/postgres/synced_tables/<CATALOG>.<SCHEMA>.<TABLE>`
- `DELETE /api/2.0/postgres/synced_tables/<CATALOG>.<SCHEMA>.<TABLE>`
- No list or update endpoint is documented.

Spec fields:
- `postgres_database` (required)
- `branch`
- `scheduling_policy` (required)
- `source_table_full_name`
- `primary_key_columns`
- `timeseries_key`
- `existing_pipeline_id` or `new_pipeline_spec{storage_catalog, storage_schema, budget_policy_id}`
- `create_database_objects_if_missing` (default true)
- `type_overrides`

### Python SDK

```python
from databricks.sdk.service.postgres import (SyncedTable, SyncedTableSyncedTableSpec,
    SyncedTableSyncedTableSpecSyncedTableSchedulingPolicy)
w.postgres.create_synced_table(
    synced_table=SyncedTable(spec=SyncedTableSyncedTableSpec(
        source_table_full_name="<SRC_CATALOG>.<SRC_SCHEMA>.<SRC_TABLE>",
        branch="projects/<PROJECT_ID>/branches/<BRANCH_ID>",
        primary_key_columns=["<PK_COLUMN>"],
        scheduling_policy=SyncedTableSyncedTableSpecSyncedTableSchedulingPolicy.SNAPSHOT,
        postgres_database="<DATABASE>",
        create_database_objects_if_missing=True)),
    synced_table_id="<CATALOG>.<SCHEMA>.<TABLE>").wait()
```

### Terraform and bundles

- Terraform: `databricks_postgres_synced_table` with `synced_table_id` and `spec = {...}`, using the same field names as the REST spec. Template: `assets/terraform/synced_table.tf`. Source: https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_synced_table.md
- Bundles: `postgres_synced_tables` (Beta, CLI 1.0.0+), with the same field names. Template: `assets/bundles/databricks.yml`.

> NOTE: the bundles settings page (https://docs.databricks.com/aws/en/dev-tools/bundles/settings) lists the legacy key `synced_database_tables` but not `postgres_synced_tables`. The resources page lists both.

## Related features

- Feature Store online tables use similar publish modes. See `apps-and-ai.md`.
- Since 2026-09, `ai_search` can search Lakebase synced tables (Beta). Source: https://docs.databricks.com/aws/en/release-notes/product/
