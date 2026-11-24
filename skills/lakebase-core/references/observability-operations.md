# Observability and operations

Last verified: 2026-11-20. Check `release-watch.md` first.

## Monitoring tools

Source: https://docs.databricks.com/aws/en/oltp/projects/monitor

Lakebase has four monitoring tools:
- Telemetry in system tables (**Beta**)
- Insights (**Beta**)
- Genie
- Metrics and activity

Metrics graphs show up to seven days of data. Query views reset when the compute suspends.

## Metrics dashboard

Source: https://docs.databricks.com/aws/en/oltp/projects/metrics

To open it, go to **Monitoring** and then the **Metrics** tab.

Graphs:
- RAM: allocated, used, and cached
- CPU
- Connections: active, idle, total, and max
- Database size
- Deadlocks
- Rows
- Compute cache hit rate. The docs target 99% or better for OLTP workloads.
- Working set size
- Replication delay. This graph appears on read replicas only.

The compute cache can use up to 75% of the compute's RAM.

Query performance:
- The **Query performance** tab shows the top 100 queries, taken from `pg_stat_statements`.
- This data is lost when the compute suspends or restarts.
- Source: https://docs.databricks.com/aws/en/oltp/projects/query-performance

System operations:
- Operation statuses are `OK`, `Scheduling`, `In progress`, and `Error`.
- Source: https://docs.databricks.com/aws/en/oltp/projects/operations

## system.lakebase system tables (Beta)

Sources: https://docs.databricks.com/aws/en/oltp/projects/observability-telemetry-reference and https://docs.databricks.com/aws/en/admin/system-tables/lakebase

Status:
- **Beta**. Table and column names might change before GA.
- Released on 2026-09-23 on AWS and Azure. The GCP release notes have no entry for it.

Retention: 7 days.

Tables:
- `active_session_history`
- `wait_event_counters`
- `plan_history`
- `pg_stat_statements_counters`
- `ddl_history`
- `database_counters`
- `database_gauges`
- `compute_counters`
- `compute_gauges`
- `postgres_logs`

Requirements:
- The "Lakebase Observability in System Tables" preview must be on.
- The "Lakeflow Connect Zerobus Ingest" and "Zerobus Ingest Default Storage" previews must also be on.

Access:
- Users who are both account admin and metastore admin can read the tables and grant access.
- Statement text shows as `<REDACTED>` unless you are an account admin or in the `databricks_pii_access` group.

Known gaps:
- COPY is not captured in plan history.
- Queries inside PL/pgSQL are not captured.

If telemetry is missing, run `SHOW neon_monitor.log_capture_enabled;` and `SHOW databricks.o11y_exporter_enabled;`. Both must return `on`. If either is off, restart the endpoint.

## OpenTelemetry export (Beta)

Source: https://docs.databricks.com/aws/en/oltp/projects/opentelemetry

Status:
- **Beta**. Released on 2026-04-20.
- The release note exists only on AWS.

What it sends:
- Metrics and logs over OTLP, from a managed collector for each project.
- Postgres metrics get a `lakebase_` prefix, for example `lakebase_connection_counts`. Host metrics keep their original names.

Setup:
- Go to Settings → Integrations → OpenTelemetry.
- Protocol: HTTP on port 4318 is recommended. gRPC on port 4317 is also supported.
- Endpoint: enter the base URL only. Lakebase appends `/v1/metrics` and `/v1/logs`.
- Auth: Bearer, Basic, or API Key. For Datadog, use the `DD-API-KEY` header.

Resource attributes:
- You can add up to 10 custom attributes.
- Keys are 1–128 characters.
- Some keys are reserved: `project_id`, `endpoint_id`, `region_id`, `host`, `k8s.*`, and others.

## Lakebase Insights (Beta)

Source: https://docs.databricks.com/aws/en/oltp/projects/observability-ai-insights

Setup:
- **Beta**. A workspace admin enables the "Lakebase Insights" preview. Its former name was "Lakebase Advanced Postgres Telemetry".
- Configure it per project in Settings → Insights.
- By default, analysis runs every 24 hours. You can switch to manual runs only. Use **Run now** on the Monitoring page.

Findings:
- Each finding shows a severity, a summary, the evidence, and recommendations.
- You can fix a finding yourself, use **Fix with Genie**, or mark it Resolved or Not an issue.
- You need CAN MANAGE to configure Insights or view findings.

Cost:
- Storing telemetry within the 7-day retention has no separate charge.
- Each Insights run counts toward compute usage and model tokens.

## Planned updates

Source: https://docs.databricks.com/aws/en/oltp/projects/updates

What updates include:
- Postgres minor versions, which are "typically released quarterly"
- Security patches
- OS updates
- New features

Platform maintenance is not covered by these updates.

Schedule:
- "Computes receive updates at least every 28 days."
- Set the update window in Settings → Updates by choosing a day of the week and an hour.
- "Lakebase posts planned updates at least 3 days in advance."
- The notice period was 7 days before 2026-07-10.

Restarts:
- An update restarts the compute, which takes "a few seconds". The cache is prewarmed automatically.
- Connections may drop briefly, so use driver retry logic.
- To apply an update early, restart the compute.
- A compute that is in a transition state at the update time gets the update later.

## Minor version upgrades

Source: https://docs.databricks.com/aws/en/oltp/projects/postgres-version-support

- You can't pin or downgrade a minor version.
- A project that misses updates jumps straight to the latest minor version.
- Lakebase occasionally sends a notice when a fix needs manual action.

For major versions, see `postgres-compatibility.md`.

## Audit logs

See `networking-security.md` for `system.access.audit` and `service_name = 'lakebase'`.
