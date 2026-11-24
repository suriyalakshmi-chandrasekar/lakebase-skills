# Sources

Every URL cited in `SKILL.md`, `references/`, and `assets/`, with the date it was fetched and the files that cite it.
Pages marked 2026-11-20 were fetched on that date during the build of version 0.1.0. Rows marked *not fetched* are links the skill points readers to; no facts in the skill rely on them.

Pages that returned HTTP 404 on 2026-11-20 and are therefore **not** sources: `https://docs.databricks.com/gcp/en/oltp/`, `https://docs.databricks.com/aws/en/oltp/release-notes`, `https://docs.databricks.com/aws/en/oltp/projects/troubleshooting`, `https://docs.databricks.com/aws/en/oltp/projects/billing`, `https://docs.databricks.com/aws/en/oltp/projects/cost-management`.
`https://docs.databricks.com/aws/en/oltp/projects/private-link` returned the Data protection page content when fetched; facts are cited to `.../data-protection` instead.
The Terraform Registry pages did not render; the provider's docs source on GitHub was used.
Skill-format conventions came from https://agentskills.io/specification, https://github.com/anthropics/skills, https://code.claude.com/docs/en/skills, https://code.claude.com/docs/en/plugin-marketplaces, and https://learn.chatgpt.com/docs/build-skills (fetched 2026-11-20; they are format references, not Lakebase sources).

## Databricks docs: Lakebase (AWS)

| URL | Fetched | Cited in |
|---|---|---|
| https://docs.databricks.com/aws/en/oltp/ | 2026-11-20 | concepts.md |
| https://docs.databricks.com/aws/en/oltp/instances/ | 2026-11-20 | concepts.md |
| https://docs.databricks.com/aws/en/oltp/projects/api-usage#cdf-endpoints | not fetched (pointer only; no facts taken from it) | lakebase-to-delta.md |
| https://docs.databricks.com/aws/en/oltp/projects/authentication | 2026-11-20 | assets/cli/lakebase-cli.sh, assets/sdk-python/connect_with_oauth.py, auth-and-roles.md, concepts.md, connect-and-data-api.md, limits-quotas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/authentication#token-rotation-examples | 2026-11-20 | auth-and-roles.md, connect-and-data-api.md |
| https://docs.databricks.com/aws/en/oltp/projects/autoscaling | 2026-11-20 | limits-quotas.md, provisioning.md |
| https://docs.databricks.com/aws/en/oltp/projects/backup-methods | 2026-11-20 | branching-and-recovery.md |
| https://docs.databricks.com/aws/en/oltp/projects/branches | 2026-11-20 | billing-model.md, branching-and-recovery.md, concepts.md |
| https://docs.databricks.com/aws/en/oltp/projects/build-applications | 2026-11-20 | apps-and-ai.md |
| https://docs.databricks.com/aws/en/oltp/projects/compatibility | 2026-11-20 | auth-and-roles.md, concepts.md, limits-quotas.md, postgres-compatibility.md |
| https://docs.databricks.com/aws/en/oltp/projects/connect | 2026-11-20 | connect-and-data-api.md, networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/connect-overview | 2026-11-20 | connect-and-data-api.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/connect-psql | 2026-11-20 | connect-and-data-api.md |
| https://docs.databricks.com/aws/en/oltp/projects/connection-pooling | 2026-11-20 | connect-and-data-api.md, limits-quotas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/connection-strings | 2026-11-20 | connect-and-data-api.md, networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/core-concepts | 2026-11-20 | concepts.md |
| https://docs.databricks.com/aws/en/oltp/projects/customer-managed-keys | 2026-11-20 | networking-security.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/data-api | 2026-11-20 | connect-and-data-api.md, ha-and-read-replicas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/data-protection | 2026-11-20 | networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/databricks-apps | 2026-11-20 | apps-and-ai.md |
| https://docs.databricks.com/aws/en/oltp/projects/disaster-recovery | 2026-11-20 | branching-and-recovery.md, ha-and-read-replicas.md, release-watch.md |
| https://docs.databricks.com/aws/en/oltp/projects/extensions | 2026-11-20 | lakebase-search.md, postgres-compatibility.md |
| https://docs.databricks.com/aws/en/oltp/projects/feature-store | 2026-11-20 | apps-and-ai.md |
| https://docs.databricks.com/aws/en/oltp/projects/framework-examples | 2026-11-20 | connect-and-data-api.md |
| https://docs.databricks.com/aws/en/oltp/projects/get-started | 2026-11-20 | concepts.md, provisioning.md |
| https://docs.databricks.com/aws/en/oltp/projects/grant-permissions-programmatically | not fetched (pointer only; no facts taken from it) | auth-and-roles.md |
| https://docs.databricks.com/aws/en/oltp/projects/high-availability | 2026-11-20 | ha-and-read-replicas.md, limits-quotas.md |
| https://docs.databricks.com/aws/en/oltp/projects/hipaa-audit-logging | 2026-11-20 | limits-quotas.md, networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/hipaa-compliance | 2026-11-20 | networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-cdf | 2026-11-20 | lakebase-to-delta.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-genie | 2026-11-20 | apps-and-ai.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-search | 2026-11-20 | lakebase-search.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-text | 2026-11-20 | lakebase-search.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-tokenizer | 2026-11-20 | lakebase-search.md, postgres-compatibility.md |
| https://docs.databricks.com/aws/en/oltp/projects/lakebase-vector | 2026-11-20 | lakebase-search.md |
| https://docs.databricks.com/aws/en/oltp/projects/logical-replication | 2026-11-20 | limits-quotas.md, logical-replication.md, networking-security.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/logical-replication-manage | 2026-11-20 | logical-replication.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/logical-replication-publication | 2026-11-20 | logical-replication.md |
| https://docs.databricks.com/aws/en/oltp/projects/logical-replication-subscription | 2026-11-20 | connect-and-data-api.md, logical-replication.md |
| https://docs.databricks.com/aws/en/oltp/projects/ltap-overview | 2026-11-20 | synced-tables.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-branches | 2026-11-20 | assets/cli/lakebase-cli.sh, branching-and-recovery.md, limits-quotas.md, provisioning.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-computes | 2026-11-20 | assets/cli/lakebase-cli.sh, billing-model.md, connect-and-data-api.md, limits-quotas.md, provisioning.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-disaster-recovery | 2026-11-20 | branching-and-recovery.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-high-availability | 2026-11-20 | ha-and-read-replicas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-project-permissions | 2026-11-20 | auth-and-roles.md, concepts.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-projects | 2026-11-20 | assets/cli/lakebase-cli.sh, auth-and-roles.md, billing-model.md, branching-and-recovery.md, concepts.md, provisioning.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-projects#limits | 2026-11-20 | limits-quotas.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-roles | 2026-11-20 | assets/cli/lakebase-cli.sh, auth-and-roles.md, limits-quotas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/manage-roles-permissions | 2026-11-20 | assets/sql/roles-and-grants.sql, auth-and-roles.md |
| https://docs.databricks.com/aws/en/oltp/projects/metrics | 2026-11-20 | observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/monitor | 2026-11-20 | observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/move-data-in-and-out | 2026-11-20 | lakebase-to-delta.md |
| https://docs.databricks.com/aws/en/oltp/projects/observability-ai-insights | 2026-11-20 | billing-model.md, observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/observability-telemetry-reference | 2026-11-20 | observability-operations.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/opentelemetry | 2026-11-20 | limits-quotas.md, observability-operations.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/operations | 2026-11-20 | observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/point-in-time-branching | 2026-11-20 | branching-and-recovery.md |
| https://docs.databricks.com/aws/en/oltp/projects/point-in-time-restore | 2026-11-20 | branching-and-recovery.md, limits-quotas.md |
| https://docs.databricks.com/aws/en/oltp/projects/postgres-clients | 2026-11-20 | connect-and-data-api.md |
| https://docs.databricks.com/aws/en/oltp/projects/postgres-roles | 2026-11-20 | assets/sql/roles-and-grants.sql, auth-and-roles.md |
| https://docs.databricks.com/aws/en/oltp/projects/postgres-version-support | 2026-11-20 | concepts.md, observability-operations.md, postgres-compatibility.md |
| https://docs.databricks.com/aws/en/oltp/projects/pricing | 2026-11-20 | billing-model.md |
| https://docs.databricks.com/aws/en/oltp/projects/private-link | 2026-11-20 | networking-security.md |
| https://docs.databricks.com/aws/en/oltp/projects/query-performance | 2026-11-20 | observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/read-replicas | 2026-11-20 | billing-model.md, ha-and-read-replicas.md |
| https://docs.databricks.com/aws/en/oltp/projects/register-uc | 2026-11-20 | troubleshooting.md, unity-catalog.md |
| https://docs.databricks.com/aws/en/oltp/projects/scale-to-zero | 2026-11-20 | limits-quotas.md, provisioning.md |
| https://docs.databricks.com/aws/en/oltp/projects/snapshots | 2026-11-20 | billing-model.md, branching-and-recovery.md, limits-quotas.md |
| https://docs.databricks.com/aws/en/oltp/projects/sql-editor | 2026-11-20 | connect-and-data-api.md, limits-quotas.md |
| https://docs.databricks.com/aws/en/oltp/projects/state-management | 2026-11-20 | apps-and-ai.md |
| https://docs.databricks.com/aws/en/oltp/projects/sync-tables | 2026-11-20 | billing-model.md, limits-quotas.md, release-watch.md, synced-tables.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/table-editor | 2026-11-20 | connect-and-data-api.md, limits-quotas.md, troubleshooting.md |
| https://docs.databricks.com/aws/en/oltp/projects/updates | 2026-11-20 | observability-operations.md |
| https://docs.databricks.com/aws/en/oltp/projects/use-cases | 2026-11-20 | lakebase-to-delta.md |
| https://docs.databricks.com/aws/en/oltp/update-to-autoscaling-dabs | 2026-11-20 | concepts.md |
| https://docs.databricks.com/aws/en/oltp/update-to-autoscaling-terraform | 2026-11-20 | concepts.md |
| https://docs.databricks.com/aws/en/oltp/upgrade-to-autoscaling | 2026-11-20 | billing-model.md, concepts.md, troubleshooting.md |

## Databricks docs: Lakebase (Azure, learn.microsoft.com)

| URL | Fetched | Cited in |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/databricks/oltp/ | 2026-11-20 | concepts.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/customer-managed-keys | 2026-11-20 | networking-security.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/data-protection | 2026-11-20 | networking-security.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/high-availability | 2026-11-20 | ha-and-read-replicas.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/manage-projects | 2026-11-20 | concepts.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/private-link | 2026-11-20 | connect-and-data-api.md, networking-security.md |
| https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/register-uc | 2026-11-20 | unity-catalog.md |
| https://learn.microsoft.com/en-us/azure/databricks/release-notes/lakebase/ | 2026-11-20 | concepts.md, release-watch.md |

## Databricks docs: Lakebase (GCP)

| URL | Fetched | Cited in |
|---|---|---|
| https://docs.databricks.com/gcp/en/oltp/projects/high-availability | not fetched (pointer only; no facts taken from it) | ha-and-read-replicas.md |
| https://docs.databricks.com/gcp/en/oltp/projects/manage-projects | 2026-11-20 | concepts.md |
| https://docs.databricks.com/gcp/en/release-notes/lakebase/ | 2026-11-20 | concepts.md, lakebase-search.md, networking-security.md, release-watch.md |

## Databricks docs: release notes

| URL | Fetched | Cited in |
|---|---|---|
| https://docs.databricks.com/aws/en/release-notes/lakebase/ | 2026-11-20 | auth-and-roles.md, branching-and-recovery.md, concepts.md, lakebase-search.md, lakebase-to-delta.md, networking-security.md, release-watch.md |
| https://docs.databricks.com/aws/en/release-notes/product/ | 2026-11-20 | release-watch.md, synced-tables.md |

## Databricks REST API reference

| URL | Fetched | Cited in |
|---|---|---|
| https://docs.databricks.com/api/postgres/v1/endpoint | 2026-11-20 | concepts.md, provisioning.md |
| https://docs.databricks.com/api/postgres/v1/postgres | 2026-11-20 | auth-and-roles.md, provisioning.md |
| https://docs.databricks.com/api/postgres/v1/project | 2026-11-20 | limits-quotas.md, provisioning.md |
| https://docs.databricks.com/api/postgres/v1/synced-table | 2026-11-20 | synced-tables.md |

## Databricks Terraform provider docs

| URL | Fetched | Cited in |
|---|---|---|
| https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_branch.md | 2026-11-20 | assets/terraform/main.tf, branching-and-recovery.md |
| https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_endpoint.md | 2026-11-20 | assets/terraform/main.tf, ha-and-read-replicas.md |
| https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_project.md | 2026-11-20 | assets/terraform/main.tf |
| https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_synced_table.md | 2026-11-20 | assets/terraform/synced_table.tf, synced-tables.md, unity-catalog.md |
| https://github.com/databricks/terraform-provider-databricks/tree/main/docs/resources | 2026-11-20 | provisioning.md |

## Databricks SDK docs

| URL | Fetched | Cited in |
|---|---|---|
| https://databricks-sdk-py.readthedocs.io/en/latest/workspace/postgres/postgres.html | 2026-11-20 | provisioning.md |

## Databricks docs: platform (system tables, bundles, CLI, security, admin)

| URL | Fetched | Cited in |
|---|---|---|
| https://docs.databricks.com/aws/en/admin/account-settings/usage-detail-tags | 2026-11-20 | billing-model.md, limits-quotas.md |
| https://docs.databricks.com/aws/en/admin/system-tables/billing | 2026-11-20 | billing-model.md, concepts.md |
| https://docs.databricks.com/aws/en/admin/system-tables/lakebase | 2026-11-20 | limits-quotas.md, observability-operations.md |
| https://docs.databricks.com/aws/en/admin/usage/budget-policies | 2026-11-20 | billing-model.md |
| https://docs.databricks.com/aws/en/agents/agent-memory/managed-memory | not fetched (pointer only; no facts taken from it) | apps-and-ai.md |
| https://docs.databricks.com/aws/en/agents/custom-agents/model-serving/stateful-agents-model-serving | not fetched (pointer only; no facts taken from it) | apps-and-ai.md |
| https://docs.databricks.com/aws/en/dev-tools/bundles/ | 2026-11-20 | provisioning.md |
| https://docs.databricks.com/aws/en/dev-tools/bundles/resources | 2026-11-20 | apps-and-ai.md, assets/bundles/databricks.yml, auth-and-roles.md, provisioning.md, release-watch.md, synced-tables.md |
| https://docs.databricks.com/aws/en/dev-tools/bundles/settings | 2026-11-20 | synced-tables.md |
| https://docs.databricks.com/aws/en/dev-tools/cli/commands | 2026-11-20 | provisioning.md |
| https://docs.databricks.com/aws/en/dev-tools/cli/reference/postgres-commands | 2026-11-20 | assets/cli/lakebase-cli.sh, synced-tables.md |
| https://docs.databricks.com/aws/en/dev-tools/databricks-apps/lakebase | not fetched (pointer only; no facts taken from it) | apps-and-ai.md |
| https://docs.databricks.com/aws/en/machine-learning/feature-store/online-feature-store#limitations | not fetched (pointer only; no facts taken from it) | apps-and-ai.md |
| https://docs.databricks.com/aws/en/resources/ip-domain-region | not fetched (pointer only; no facts taken from it) | connect-and-data-api.md |
| https://docs.databricks.com/aws/en/tables/features/change-data-feed | 2026-11-20 | synced-tables.md |

## Databricks legal / pricing

| URL | Fetched | Cited in |
|---|---|---|
| https://www.databricks.com/legal/sla/lakebase-sla | 2026-11-20 | ha-and-read-replicas.md |
| https://www.databricks.com/product/pricing/lakebase | not fetched (pointer only; no facts taken from it) | billing-model.md |

## PostgreSQL docs

| URL | Fetched | Cited in |
|---|---|---|
| https://www.postgresql.org/docs/current/textsearch.html | not fetched (pointer only; no facts taken from it) | postgres-compatibility.md |
