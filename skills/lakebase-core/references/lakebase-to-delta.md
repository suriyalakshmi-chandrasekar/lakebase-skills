# Lakebase → Delta (Lakebase Change Data Feed, formerly "Lakehouse sync")

Last verified: 2026-11-20. Check `release-watch.md` first.

## Naming and status

| Name | Status | Date | Source |
|---|---|---|---|
| "Lakehouse sync (Beta)" | Beta | 2026-03-12 | AWS release notes: https://docs.databricks.com/aws/en/release-notes/lakebase/ |
| "Lakebase Change Data Feed (CDF)" / "Store Postgres changes in the lakehouse" | **Public Preview** | 2026-05-12 | https://docs.databricks.com/aws/en/oltp/projects/lakebase-cdf |

- The current docs have no page titled "Lakehouse sync". The feature is now documented as **Lakebase Change Data Feed**: "The Lakebase Change Data Feed feature is in Public Preview."
- The Azure release notes list CDF Public Preview on 2026-05-12, but have no "Lakehouse sync" entry. The GCP release notes list neither.
- To turn it on, a workspace admin enables the Lakebase Change Data Feed preview on the workspace **Previews** page.

## How it works

Sources: https://docs.databricks.com/aws/en/oltp/projects/lakebase-cdf and https://docs.databricks.com/aws/en/oltp/projects/use-cases

Capture:
- "Every insert, update, and delete on a Lakebase Postgres table is captured from the write-ahead log and stored as a new row in a Unity Catalog managed Delta table, batched and flushed every ~15 seconds."
- The capture is done by the `wal2delta` extension, which uses logical decoding.
- "The capture path runs on independent compute, so production queries are unaffected."

Scope:
- A feed covers one schema and includes every current and future table in it.
- Each schema can have only one feed, and each feed reads from one source database.

Output:
- Each source table writes to a destination table named `lb_<table_name>_history`.
- If two names collide, the second destination gets the suffix `_1`.
- "The history table has the same shape as Delta Change Data Feed".
- An initial snapshot writes the existing rows as insert events. A table appears only once it has at least one row.

## Prerequisites

- Postgres 16, 17, or 18.
- `REPLICA IDENTITY FULL` on each table.
- In Unity Catalog: USE CATALOG, USE SCHEMA, and CREATE TABLE on the destination.
- CAN MANAGE on the project.
- The destination catalog must not use default storage.

> UNVERIFIED: whether CDF supports Postgres 19. The CDF page lists only 16–18.

```sql
ALTER TABLE <TABLE> REPLICA IDENTITY FULL;
```

The page also gives a `DO $$` loop that applies this to every table in a schema, and an event trigger that applies it to new tables.

## Start, monitor, stop

Start:
1. Open the branch overview and go to the **Lakebase CDF** tab.
2. Click **Start**.
3. Choose the source database and schema, then the destination catalog and schema.

API endpoints for CDF are listed at https://docs.databricks.com/aws/en/oltp/projects/api-usage#cdf-endpoints. The CLI has `list-cdf-configs` and `list-cdf-statuses`.

Monitor:
- In the UI, the Tables sub-tab shows a status ("Streaming" or "Snapshotting"), the Committed LSN, and the last update time.
- In SQL, run `SELECT * FROM wal2delta.tables;`.

Stop:
- Click **Disable** on the Lakebase CDF tab. This stops the feed for all schemas in the project.

## Destination columns

| Column | Type | Values |
|---|---|---|
| `_pg_change_type` | TEXT | `insert`, `delete`, `update_preimage`, `update_postimage` |
| `_pg_lsn` | BIGINT | |
| `_pg_xid` | INTEGER | |
| `_timestamp` | TIMESTAMP, no timezone | |
| `_sort_by` | BIGINT | |

## Type mapping (Postgres → Delta)

| Postgres | Delta |
|---|---|
| BOOLEAN | BOOLEAN |
| INT / SMALLINT / BIGINT | same type |
| TEXT / VARCHAR / CHAR | STRING |
| DATE | DATE |
| TIMESTAMP | TIMESTAMP_NTZ |
| TIMESTAMPTZ | TIMESTAMP |
| FLOAT / DOUBLE | FLOAT / DOUBLE |
| JSONB, ENUM | STRING |
| NUMERIC | DECIMAL, or STRING when precision is above 38 or undefined |
| PostGIS types, `vector`, composite types, `hstore` | STRING |

All NUMERIC columns are nullable in Delta, because NaN maps to NULL.

> UNVERIFIED: how arrays, `bytea`, and `interval` map. They aren't listed in the docs.

## Schema changes

- Renaming a table: the feed continues, and the destination keeps its old name.
- Adding, dropping, or changing the type of a column: the affected table is snapshotted again.
- Dropping a source table: the destination is kept.

## Limitations

- Partitioned tables aren't supported.
- Don't add row filters or column masks to the destination. Don't enable Delta CDF on the destination either.
- CDF isn't supported when the destination catalog's storage is reachable only through a private endpoint.
- After a disaster-recovery failover, CDF pipelines stop and don't resume. See `branching-and-recovery.md`.

> UNVERIFIED: CDF billing, table-count limits, and throughput limits. None were found in the docs.

## Other ways out of Lakebase

Native logical replication to an external Postgres subscriber is covered in `logical-replication.md`. The general overview is at https://docs.databricks.com/aws/en/oltp/projects/move-data-in-and-out.
