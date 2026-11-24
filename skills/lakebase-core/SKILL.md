---
name: lakebase-core
description: Expert reference for Databricks Lakebase (Lakebase Postgres), the managed Postgres OLTP database in Databricks. Use it for any question about Lakebase, Lakebase Postgres, Databricks Postgres or Databricks OLTP - projects, branches, computes and endpoints, autoscaling and scale-to-zero, instant restore and snapshots, high availability and read replicas, connecting with psql or drivers, OAuth tokens and OAuth roles, password login, the Data API, private connectivity, CMK, compliance, Unity Catalog registration, synced tables (Delta to Lakebase), Lakebase Change Data Feed or Lakehouse sync (Lakebase to Delta), logical replication, Lakebase Search (lakebase_vector, lakebase_text, lakebase_tokenizer), Postgres versions and extensions, Databricks Apps, monitoring, limits, billing and troubleshooting. Covers CLI, REST, SDK, Terraform and bundle syntax, citing official docs with a last-verified date. It does NOT cover migrating data from other systems into Lakebase; for that use the lakebase-migration skill.
license: MIT
compatibility: Needs internet access to docs.databricks.com and learn.microsoft.com to check release notes. scripts/check_release_notes.py needs Python 3.9+ (standard library only). The asset templates assume the Databricks CLI, Databricks SDK for Python, or the Databricks Terraform provider.
metadata:
  version: "0.1.0"
  last-verified: "2026-11-20"
---

# Lakebase core

This skill makes you an expert on **Databricks Lakebase**, the managed Postgres OLTP database in Databricks. Everything in `references/` comes from official Databricks docs, the Databricks Terraform provider docs, or postgresql.org. Every fact has its source URL next to it. Docs were last verified on **2026-11-20**.

## Rules

1. **Check `references/release-watch.md` before you state any feature, limit, region, or preview status.** If you can, run `python scripts/check_release_notes.py`. It lists release-note entries newer than `metadata.last-verified`. If a newer entry contradicts a reference file, the docs win. Say so.
2. **Show the date.** When an answer depends on a fact from this skill, say "per Databricks docs, last verified 2026-11-20" and give the source URL.
3. **Don't fill gaps from memory.** If a reference says `UNVERIFIED`, or doesn't cover the question, say so. Point to the doc page to check.
4. **Keep the clouds apart.** AWS, Azure, and GCP differ in regions, release dates, preview status, and compliance. Never merge them into one answer. Report `CONFLICT` notes as written.
5. **Quote preview labels exactly** as written: Beta, Public Preview, Private Preview, GA.
6. **Never quote prices.** Link to the pricing page instead.
7. **Use the current model.** New work uses Autoscaling *projects*: project → branch → compute (endpoint) → database. "Provisioned" instances are legacy. Mention them only for upgrades.
8. **Migration is out of scope.** For moving data into Lakebase from another database or system, say this skill doesn't cover it and point to the `lakebase-migration` skill.

## Quick decision guide

| The user asks about… | Read |
|---|---|
| What Lakebase is; project, branch, compute, endpoint, database, role; regions; legacy Provisioned and the upgrade | [concepts.md](references/concepts.md) |
| Creating projects, branches, or computes; CU sizes; autoscaling; scale-to-zero; CLI, REST, SDK, Terraform, or bundles | [provisioning.md](references/provisioning.md) |
| Branches, instant restore, point-in-time queries, snapshots, backup schedules, disaster recovery, undeleting a project | [branching-and-recovery.md](references/branching-and-recovery.md) |
| High availability, failover, read replicas, SLA | [ha-and-read-replicas.md](references/ha-and-read-replicas.md) |
| Connection strings, TLS, psql, drivers, connection limits, PgBouncer pooling, SQL Editor, Tables editor, Data API | [connect-and-data-api.md](references/connect-and-data-api.md) |
| OAuth tokens, OAuth roles, password login, `databricks_auth`, grants, project permissions | [auth-and-roles.md](references/auth-and-roles.md) |
| Private Link or PSC, IP allowlists, encryption, CMK, HIPAA, PCI, SOC 2, audit logs | [networking-security.md](references/networking-security.md) |
| Registering a database in Unity Catalog, querying it from Databricks SQL | [unity-catalog.md](references/unity-catalog.md) |
| Synced tables (Delta to Lakebase): modes, CDF, keys, types, LTAP Direct Writes, capacity | [synced-tables.md](references/synced-tables.md) |
| Lakebase to Delta: Lakebase Change Data Feed (formerly "Lakehouse sync") | [lakebase-to-delta.md](references/lakebase-to-delta.md) |
| Native logical replication in or out: publications, subscriptions, slots | [logical-replication.md](references/logical-replication.md) |
| Vector, BM25, or hybrid search; tokenizers; CJK | [lakebase-search.md](references/lakebase-search.md) |
| Postgres versions, extensions, unsupported features | [postgres-compatibility.md](references/postgres-compatibility.md) |
| Databricks Apps, Feature Store, agent memory, Genie | [apps-and-ai.md](references/apps-and-ai.md) |
| Metrics, `system.lakebase`, OpenTelemetry, Insights, update windows, minor versions | [observability-operations.md](references/observability-operations.md) |
| Any numeric limit or quota | [limits-quotas.md](references/limits-quotas.md) |
| What is billed, usage records, budget policies, tags | [billing-model.md](references/billing-model.md) |
| An error message or failure | [troubleshooting.md](references/troubleshooting.md) |
| Whether something is new, changed, or still in preview | [release-watch.md](references/release-watch.md) |
| Where a fact came from | [sources.md](references/sources.md) |

## Templates

Templates in `assets/` use documented syntax with `<PLACEHOLDER>` values:

| Template | Contents |
|---|---|
| `assets/terraform/main.tf` | Project, branch, and computes |
| `assets/terraform/synced_table.tf` | Unity Catalog catalog and synced table |
| `assets/bundles/databricks.yml` | `postgres_*` bundle resources (Beta) |
| `assets/cli/lakebase-cli.sh` | CLI reference sheet |
| `assets/sdk-python/connect_with_oauth.py` | OAuth token and psycopg connection |
| `assets/sql/roles-and-grants.sql` | OAuth roles and grants |

Tell the user to check templates against the linked doc page before use.

## How to answer

1. Find the topic in the guide above and read only that reference file.
2. Check `release-watch.md` for anything newer.
3. Answer using the docs' own terms. Include the source URL and "last verified 2026-11-20".
4. Flag anything marked `UNVERIFIED` or `CONFLICT` in the reference file.
