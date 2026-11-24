# Billing model (no prices)

Last verified: 2026-11-20. Check `release-watch.md` first.

This file never quotes prices. Send users to the Lakebase pricing page: https://www.databricks.com/product/pricing/lakebase. The docs link https://docs.databricks.com/aws/en/oltp/projects/pricing redirects there.

> UNVERIFIED: the docs have no dedicated Lakebase billing page. Each fact below is taken from the page cited next to it.

## What is billed

### Compute

- "Larger computes consume more compute hours over the same period of active time than smaller computes."
  Source: https://docs.databricks.com/aws/en/oltp/projects/manage-computes
- Scale-to-zero stops compute while the database is idle. See `provisioning.md`.
- A compute with an active logical-replication subscriber doesn't scale to zero.

### Storage

- Only actual data counts toward the storage quota. Point-in-time restore history does not.
- "Extending the history window increases your storage."
  Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects

### Branches

- An expiring branch is billed only for the data that changed on it.
- A permanent branch "is billed for its full data size."
  Source: https://docs.databricks.com/aws/en/oltp/projects/branches

### Read replicas

- Read replicas add "No additional storage costs."
  Source: https://docs.databricks.com/aws/en/oltp/projects/read-replicas

### Snapshot storage

- "Starting June 1, 2026, snapshot storage is billable for Lakebase."
- Manual snapshots are charged as full snapshots.
- A scheduled series charges the first snapshot as full. Later snapshots are charged as incremental.
- Source: https://docs.databricks.com/aws/en/oltp/projects/snapshots

### Synced tables

- Synced tables run on managed Lakeflow pipelines. You can pick a serverless usage policy (`budget_policy_id`) for the pipeline.
- Source: https://docs.databricks.com/aws/en/oltp/projects/sync-tables

> UNVERIFIED: which billing product synced-table pipelines are charged under.

### Insights

- Each Insights run counts toward compute usage and model tokens.
- Storing telemetry within the 7-day retention has no separate charge.
- Source: https://docs.databricks.com/aws/en/oltp/projects/observability-ai-insights

### After the Provisioned upgrade

- "Lakebase GA pricing applies after the upgrade."
- Source: https://docs.databricks.com/aws/en/oltp/upgrade-to-autoscaling

## Usage records

Source: https://docs.databricks.com/aws/en/admin/system-tables/billing

- Usage is recorded in the table `system.billing.usage`.
- `billing_origin_product` values:
  - `LAKEBASE`: "the current version of Lakebase"
  - `DATABASE`: Lakebase Provisioned instances
- `usage_type` values include `COMPUTE_TIME`, `STORAGE_SPACE`, `NETWORK_BYTE`, and `NETWORK_HOUR`.
- Records usually appear within 12 hours.

## Budget policies and tags

Budget policies (serverless usage policies):
- Choose a policy when you create a project, or later in General settings.
- Users who have more than one policy must pick one.
- Tags flow into `system.billing.usage.custom_tags`.
- Sources: https://docs.databricks.com/aws/en/oltp/projects/manage-projects and https://docs.databricks.com/aws/en/admin/usage/budget-policies

Custom tags:
- Set them in the project's General settings, or with the API field `spec.custom_tags`.
- Setting tags through the API replaces all existing tags.
- A resource can have at most 20 tags.
- Tag changes can take up to one hour to propagate.
- Source: https://docs.databricks.com/aws/en/admin/account-settings/usage-detail-tags

Budget policies and tags became available on 2026-03-12 (release notes, AWS and Azure).
