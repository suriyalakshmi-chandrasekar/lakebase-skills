# Troubleshooting

Last verified: 2026-11-20. Check `release-watch.md` first.

There is no dedicated Lakebase troubleshooting page. The URLs `oltp/projects/troubleshooting` and `oltp/projects/troubleshoot` both returned 404 on 2026-11-20. Every entry below comes from the feature page linked in its Source column.

## Connections and authentication

| Symptom / error | Cause and fix | Source |
|---|---|---|
| psql hangs after pasting an OAuth token | Export `PGPASSWORD` instead of pasting the token. If psql still prompts, run `unset PGSERVICE PGSERVICEFILE`. | https://docs.databricks.com/aws/en/oltp/projects/connect-overview |
| Password login fails on a new project | Password connections are off by default for new projects. Turn on `spec.enable_pg_native_login` (see `auth-and-roles.md`). | https://docs.databricks.com/aws/en/oltp/projects/manage-roles |
| OAuth login fails through the pooler | The pooler doesn't support OAuth roles. Use a direct connection, or a password role. | https://docs.databricks.com/aws/en/oltp/projects/connection-pooling |
| JDBC errors about prepared statements | Set `prepareThreshold=0`. | https://docs.databricks.com/aws/en/oltp/projects/connection-pooling |
| Errors from `SET`, `LISTEN`, advisory locks, or `pg_dump` through the pooler | Transaction-mode limits. Use a direct connection, or `ALTER ROLE ... SET`. | https://docs.databricks.com/aws/en/oltp/projects/connection-pooling |
| Token rejected | The token is older than 1 hour, or comes from a different workspace. Generate a new one. | https://docs.databricks.com/aws/en/oltp/projects/authentication |
| Upgraded instance returns "The endpoint has been disabled. Enable it using the API and retry" | The instance was paused before the upgrade. Enable the endpoint through the API. | https://docs.databricks.com/aws/en/oltp/upgrade-to-autoscaling |
| "endpoint not found" or "connection refused" | The project may be soft-deleted. Check with `list-projects --show-deleted`. | https://docs.databricks.com/aws/en/oltp/projects/manage-projects |
| Error connecting when many computes are active | The project has hit the limit of 20 concurrently active computes. Suspend some computes, or request an increase. | https://docs.databricks.com/aws/en/oltp/projects/manage-projects |
| New project ID rejected | Deleted project IDs stay reserved for 7 days. Purge the old project first. | https://docs.databricks.com/aws/en/oltp/projects/manage-projects |
| Data API `GRANT ... TO authenticator` fails with SQLSTATE 42501 | The role was created in the UI. Create it with `databricks_create_role` in SQL instead. | https://docs.databricks.com/aws/en/oltp/projects/data-api |
| Data API write returns HTTP 405 / 25006 | The request went to a read replica. Send writes to the read-write endpoint. | https://docs.databricks.com/aws/en/oltp/projects/data-api |

## Compute settings

| Symptom / error | Cause and fix | Source |
|---|---|---|
| Error when setting a suspend timeout | Scale-to-zero is only available up to 32 CU. Also, `no_suspension: false` is invalid. | https://docs.databricks.com/aws/en/oltp/projects/manage-computes |
| Can't enable HA | Turn off scale-to-zero (`no_suspension: true`), and keep the autoscaling spread at 16 CU or less. | https://docs.databricks.com/aws/en/oltp/projects/manage-high-availability |

## Synced tables

| Symptom / error | Cause and fix | Source |
|---|---|---|
| `ERROR: invalid byte sequence for encoding "UTF8": 0x00` or `unsupported Unicode escape sequence ... \u0000 cannot be converted to text` | The source data has null bytes. Strip them with `REPLACE`, or convert the column to BINARY. | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Sync fails while an index is building | The index build took more than 20 minutes during a sync, and the sync isn't retried. Build the index with `CREATE INDEX` (not CONCURRENTLY) outside the sync window. | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Pipeline fails because of duplicate keys | Set a timeseries key. | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |
| Status shows INITIALIZING for a long time | This is expected for large syncs. | https://docs.databricks.com/aws/en/oltp/projects/sync-tables |

## Unity Catalog

| Symptom / error | Cause and fix | Source |
|---|---|---|
| `PERMISSION_DENIED` (`UC_LAKEBASE_CATALOG_ACCESS_DENIED`) | You used classic compute or a Pro warehouse. Use serverless compute. | https://docs.databricks.com/aws/en/oltp/projects/register-uc |
| Registering a branched database fails | Registering a branch isn't supported. | https://docs.databricks.com/aws/en/oltp/projects/register-uc |

## Logical replication

| Symptom / error | Cause and fix | Source |
|---|---|---|
| `CREATE SUBSCRIPTION` fails with "restricted by Account Network Policies" | Allow the source host in the account network policy. | https://docs.databricks.com/aws/en/oltp/projects/logical-replication |
| `DROP DATABASE` fails | The database still has subscriptions. Drop them first. | https://docs.databricks.com/aws/en/oltp/projects/logical-replication-manage |

## Observability and editors

| Symptom / error | Cause and fix | Source |
|---|---|---|
| No telemetry in `system.lakebase` | `SHOW neon_monitor.log_capture_enabled;` and `SHOW databricks.o11y_exporter_enabled;` must both return `on`. If either is off, restart the endpoint. Also check the required previews. | https://docs.databricks.com/aws/en/oltp/projects/observability-telemetry-reference |
| OpenTelemetry shows "No data", "HTTP 404 on export", or "Validation errors when saving" | Check the URL, protocol, and credentials. Use the base URL only, or path overrides. Check the firewall and TLS. | https://docs.databricks.com/aws/en/oltp/projects/opentelemetry |
| Tables editor returns HTTP 507 "response is too large" | The preview is larger than 64 MB. Use a Postgres client instead. | https://docs.databricks.com/aws/en/oltp/projects/table-editor |
| CMK banner: "Database projects unavailable due to key access issue." | The key was revoked or can't be reached. Restore key access. | https://docs.databricks.com/aws/en/oltp/projects/customer-managed-keys |
