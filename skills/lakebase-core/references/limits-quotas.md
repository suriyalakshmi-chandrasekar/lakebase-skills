# Limits and quotas (consolidated)

Last verified: 2026-11-20. Limits change often, so check `release-watch.md` and the source page before quoting any value.

Most limits come from the **Project limits** table:

| Short name | URL |
|---|---|
| MP | https://docs.databricks.com/aws/en/oltp/projects/manage-projects#limits |
| MC | https://docs.databricks.com/aws/en/oltp/projects/manage-computes |

The Source column below uses these short names, or gives the full URL.

| Limit | Value | Source |
|---|---|---|
| Concurrently active computes per project | 20 (the default branch is exempt) | MP |
| Read replicas per branch | 6 | MP |
| Branches per project | 500 | MP |
| Root branches per project | 3 | MP |
| Protected branches per project | 1 | MP |
| Postgres roles per branch | 500 | MP |
| Postgres databases per branch | 500 | MP |
| Database storage quota per branch | "Adjustable on request" | MP |
| Projects per workspace | 1000 | MP |
| Manual snapshots per project | 10 | MP |
| History (restore) window | 2–30 days, default 7 (UI) | MP; https://docs.databricks.com/aws/en/oltp/projects/point-in-time-restore |
| Scale-to-zero timeout | 60 seconds – 7 days, default 24 hours | MP; https://docs.databricks.com/aws/en/oltp/projects/scale-to-zero |
| Scale-to-zero eligibility | Computes of 32 CU or less, without HA | MC; https://docs.databricks.com/aws/en/oltp/projects/autoscaling |
| Autoscaling compute size | 0.5–64 CU | MC |
| Fixed-size compute size | Up to 112 CU | MC |
| Autoscaling spread | max − min ≤ 16 CU | MC |
| RAM per CU | About 2 GB | MC |
| Max connections, direct | 105 (0.5 CU) up to 3993 (24 CU and above). Full table in `connect-and-data-api.md`. | MC |
| Pooler client connections | 10,000 | https://docs.databricks.com/aws/en/oltp/projects/connection-pooling |
| Idle connection timeout | 24 hours | https://docs.databricks.com/aws/en/oltp/projects/authentication |
| Maximum connection lifetime | 3 days | https://docs.databricks.com/aws/en/oltp/projects/authentication |
| OAuth token lifetime | 1 hour | https://docs.databricks.com/aws/en/oltp/projects/authentication |
| Role name length | 63 characters | https://docs.databricks.com/aws/en/oltp/projects/manage-roles |
| HA secondaries | 1–3 | https://docs.databricks.com/aws/en/oltp/projects/high-availability |
| Branch expiration | Up to 30 days | https://docs.databricks.com/aws/en/oltp/projects/manage-branches |
| Backup schedule retention | 1 hour – 35 days | https://docs.databricks.com/aws/en/oltp/projects/snapshots |
| Soft-deleted project retention | 7 days | MP |
| Synced tables per source table | 20 | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Connections per synced table | Up to 16 | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Synced table write rate | About 150 rows/s per CU (Continuous and Triggered); up to 2,000 rows/s per CU (Snapshot) | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Synced table size guidance | Not more than 1 TB for tables that need refreshes (recommendation) | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Index build while a sync waits | Fails after 20 minutes | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Logical replication slots and WAL senders | 10 each (raise by contacting Databricks) | https://docs.databricks.com/aws/en/oltp/projects/logical-replication |
| Inactive publisher slot removal | About 40 hours | https://docs.databricks.com/aws/en/oltp/projects/logical-replication |
| Compute-local temp space | 20 GiB or 15 GiB × max CU, whichever is higher | https://docs.databricks.com/aws/en/oltp/projects/compatibility |
| SQL Editor result size (Private Link proxy) | 32 MB | https://docs.databricks.com/aws/en/oltp/projects/sql-editor |
| Tables editor preview size | 64 MB (HTTP 507 when exceeded) | https://docs.databricks.com/aws/en/oltp/projects/table-editor |
| system.lakebase retention | 7 days | https://docs.databricks.com/aws/en/admin/system-tables/lakebase |
| Audit log retention (`system.access.audit`) | 395 days by default | https://docs.databricks.com/aws/en/oltp/projects/hipaa-audit-logging |
| OpenTelemetry custom resource attributes | 10 | https://docs.databricks.com/aws/en/oltp/projects/opentelemetry |
| Tags per workspace resource | 20 | https://docs.databricks.com/aws/en/admin/account-settings/usage-detail-tags |
| vector(n) dimension (type override) | 1–16,000 | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |

> CONFLICT: the history window is 2–30 days in the UI, but 2–35 days in the API reference (https://docs.databricks.com/api/postgres/v1/project).

> CONFLICT: the default production compute is listed as both "8 - 16 CU" and "2 ↔ 4 CU" on MP.

> NOTE: the values above come from AWS pages. The Azure and GCP manage-projects pages use the same structure, but were not compared row by row.
