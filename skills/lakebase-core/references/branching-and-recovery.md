# Branching, backups, and recovery

Last verified: 2026-11-20. Check `release-watch.md` first.

## Branches

Sources: https://docs.databricks.com/aws/en/oltp/projects/branches and https://docs.databricks.com/aws/en/oltp/projects/manage-branches

How branches work:
- Branches are copy-on-write. Creating one takes the same time regardless of database size.
- Changes on a child branch don't affect its parent. Changes on a parent reach a child only if you reset the child.

Default branch:
- Every project starts with a `production` branch.
- You can make any branch the default. The default branch doesn't count toward the concurrent-compute limit.
- "Setting a branch as default is not supported using the API."

Protected branch:
- A protected branch "cannot be deleted or reset from their parent."
- A project can have only one protected branch.
- A protected branch is never archived for inactivity.
- You can't delete a project while it has a protected branch.

Expiration:
- UI presets: 1 hour, 1 day, 7 days, a custom value of up to 30 days, or Never.
- An expiring branch can't have children.
- Protected and default branches can't expire.

Reset:
- A reset copies the parent's state onto the child. It only goes from parent to child.
- You can't reset a child that has its own children.
- "Existing connections are temporarily interrupted during the reset."

Delete:
- Deleting a branch is permanent. Branches have no soft-delete.
- You can't delete a branch that has children.

Archiving:
- An inactive branch with no running compute "may be archived".
- It is unarchived automatically when accessed.

Storage billing:
- An expiring branch is billed only for the data that changed.
- A permanent branch "is billed for its full data size."

Create a branch:
- CLI: `databricks postgres create-branch projects/<PROJECT_ID> <BRANCH_ID> --json '{"spec": {"source_branch": "projects/<PROJECT_ID>/branches/production", "ttl": "604800s"}}'`
- REST: `POST /api/2.0/postgres/projects/<PROJECT_ID>/branches?branch_id=<BRANCH_ID>`

Limits are in `limits-quotas.md`: 500 branches per project, 3 root branches, 1 protected branch.

## Instant restore (point-in-time restore)

Source: https://docs.databricks.com/aws/en/oltp/projects/point-in-time-restore

Restore window:
- "You can configure the restore window from 2 days up to 30 days, with a default of 7 days."
- Set it in project Settings with the History window slider. It applies to every branch in the project.
- "Extending the history window increases your storage." (https://docs.databricks.com/aws/en/oltp/projects/manage-projects)

How to restore:
1. Open **Backup & Restore**.
2. Under **Restore from history**, choose the branch and the date and time.
3. Optionally preview the data.
4. Click **Restore**.

What a restore does:
- It creates a **new root branch**. The original branch is unchanged, so the restore is not in place.
- All databases on the branch are restored.
- You must point your application at the new branch.

## Point-in-time queries

Source: https://docs.databricks.com/aws/en/oltp/projects/point-in-time-branching

- To query a past point in time, create a branch from that point and query the branch. In the UI, choose "Branch data and schema from a past point in time".
- "You can only query data from within your configured restore window."
- Delete the branch when you're done.
- No SQL time-travel syntax is documented.

## Snapshots and the Snapshots API

Source: https://docs.databricks.com/aws/en/oltp/projects/snapshots

API status:
- The Snapshots API became GA on 2026-10-26 on AWS, Azure, and GCP. It was Beta from 2026-09-15.
- Source: https://docs.databricks.com/aws/en/release-notes/lakebase/

What a snapshot is:
- "A snapshot is a point-in-time capture of a project's root branch, including the schema and all data."

Manual snapshots:
- Manual snapshots work only on root branches. The limit is 10 per project.
- The UI's default expiration is "After 14 days".
- Snapshots can't be updated. "Deleted snapshots can't be recovered."

Billing:
- "Starting June 1, 2026, snapshot storage is billable for Lakebase."
- Manual snapshots are charged as full snapshots.
- Scheduled snapshots are charged in full for the first one, then as incremental storage.

REST endpoints (all under `/api/2.0/postgres`):

```
POST   /projects/<PROJECT_ID>/snapshots?snapshot_id=<SNAPSHOT_ID>
GET    /projects/<PROJECT_ID>/snapshots?page_size=20
GET    /projects/<PROJECT_ID>/snapshots/<SNAPSHOT_ID>
DELETE /projects/<PROJECT_ID>/snapshots/<SNAPSHOT_ID>
GET    /projects/<PROJECT_ID>/operations/<OPERATION_ID>
```

Create spec:
- `source_branch` is required.
- Set exactly one of `expire_time`, `ttl`, or `no_expiry`.
- Optionally set `source_branch_lsn` or `source_branch_time`, but not both.

CLI commands:
- `create-snapshot`, `list-snapshots`, `get-snapshot`, `delete-snapshot`
- `get-snapshot-schedule`, `update-snapshot-schedule`. The schedule commands need Databricks CLI 1.16.0 or later.

Restore from a snapshot:
- You can't restore a snapshot in place. Instead, create a branch with `spec.source_snapshot`.
- The snapshot must be AVAILABLE and in the same project.
- You can't combine `source_snapshot` with `source_branch`, an LSN, or a time.
- Terraform example: `spec = { source_snapshot = "projects/<PROJECT_ID>/snapshots/<SNAPSHOT_ID>", no_expiry = true }`
- Source: https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_branch.md

## Backup schedules

Source: https://docs.databricks.com/aws/en/oltp/projects/snapshots

API status:
- The backup schedule API became GA on 2026-10-26. It was Beta from 2026-09-22.
- Source: https://docs.databricks.com/aws/en/release-notes/lakebase/

Schedule options:
- No schedule (the default), Daily, Weekly, or Monthly.
- Times are whole hours in UTC. Weekly schedules also take a `day_of_week`. Monthly schedules take a day from 1 to 31.

Retention:
- "at least 1 hour and at most 35 days."

Scope:
- Each root branch has its own schedule.
- Scheduled snapshots don't count toward the manual-snapshot limit.

Endpoint:
- `PATCH /api/2.0/postgres/projects/<PROJECT_ID>/branches/<BRANCH_ID>/snapshot-schedule?update_mask=schedule`
- An empty schedule list disables the schedule.

> CONFLICT: the docs show the disable body two ways. The REST example uses `{"snapshot_schedule": {"schedule": []}}`. The CLI and other REST examples use `{"schedule": []}`.

## Disaster recovery (secondary workspace in another region)

Sources: https://docs.databricks.com/aws/en/oltp/projects/disaster-recovery and https://docs.databricks.com/aws/en/oltp/projects/manage-disaster-recovery

Status:
- **"Disaster recovery is in Private Preview."** "During the Private Preview, disaster recovery is not intended for production use."
- To get access, a workspace admin contacts the Databricks account team.
- The AWS overview lists disaster recovery as a key feature. The Azure overview does not.

Requirements:
- The primary and secondary workspaces must be in different regions.
- Replication runs periodically. The recovery point objective (RPO) is "in the minutes range."

Setup:
1. Open project Settings.
2. Go to **Cross-Workspace Replication**.
3. Choose the secondary workspace.
4. Click **Save** and **Enable**.

The secondary project is read-only and includes all branches.

Failover:
- Failover is manual. Use **Promote secondary** and then **Failover**.
- "Failover involves downtime."
- The new primary has a new connection string, so clients need a new token.

Recovery branches:
- Transactions that weren't replicated are kept in a `-recovery` branch.
- These branches are never deleted automatically.

Not supported during the preview:
- Cross-region read replicas
- Switchover
- A global endpoint
- PrivateLink. Replication uses the public internet, encrypted in transit.

Effect on other features:
- Synced tables need their pipelines reconfigured after failover.
- Lakebase Change Data Feed (CDF) pipelines stop and do not resume.

## Project deletion and soft-delete

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects

Soft-delete:
- "When you delete a project, it enters a soft-deleted state by default and is retained for 7 days before being permanently deleted."
- The feature was added on 2026-05-15 on AWS and Azure. The GCP release notes have no entry for it.

Commands:

| Action | CLI | REST |
|---|---|---|
| Find deleted projects | `databricks postgres list-projects --show-deleted` | `GET /api/2.0/postgres/projects?show_deleted=true` |
| Recover a project | `databricks postgres undelete-project projects/<PROJECT_ID>` | `POST /api/2.0/postgres/projects/<PROJECT_ID>/undelete` |
| Delete permanently | `databricks postgres delete-project projects/<PROJECT_ID> --purge` | `DELETE /api/2.0/postgres/projects/<PROJECT_ID>?purge=true` |

The API reference marks `show_deleted`, `purge`, and undelete as **Beta**.

While a project is soft-deleted:
- Connections fail with generic errors such as "endpoint not found" or "connection refused".
- Its project ID stays reserved for 7 days.
- Only users with CAN MANAGE can delete a project.

## Backup methods overview

https://docs.databricks.com/aws/en/oltp/projects/backup-methods compares instant restore, snapshots, and other options.
