# Release watch

**Last verified: 2026-11-20.** The newest release-note entry verified was **2026-11-19**: "Lakebase now supports Postgres 19". It appears on all three clouds.

## Instructions for the agent

1. **Before you state any feature, limit, region, or preview status**, check the release notes below for entries newer than the "Last verified" date. Run `python scripts/check_release_notes.py` if you can, or fetch the pages yourself.
2. If a newer entry contradicts a reference file, **the docs win**. Say so, and cite the newer URL.
3. When an answer depends on a fact from this skill, show its "Last verified" date. For example: "(per Databricks docs, last verified 2026-11-20)".
4. Check each cloud separately. The three clouds release features at different times. For example, Lakebase Search is GA on AWS and Azure but Beta on GCP.
5. The "Last updated" header on the release-notes pages is stale. On 2026-11-20 it still read Sep 11, 2026. Read the entry dates, not the header.

## Release notes pages

| Cloud | URL |
|---|---|
| AWS | https://docs.databricks.com/aws/en/release-notes/lakebase/ |
| Azure | https://learn.microsoft.com/en-us/azure/databricks/release-notes/lakebase/ |
| GCP | https://docs.databricks.com/gcp/en/release-notes/lakebase/ |
| Platform-wide (some Lakebase items appear only here) | https://docs.databricks.com/aws/en/release-notes/product/ |

Each entry has a heading title, followed by a bold date line such as `**November 19, 2026**`. The date format is "Month D, YYYY".

## Status snapshot as of 2026-11-20

Read each item as "on cloud X, status Y". "—" means the cloud's release notes have no entry for that item.

| Item | AWS | Azure | GCP |
|---|---|---|---|
| Lakebase overall | GA (2026-01-22) | GA (2026-03-02) | GA (2026-10-30) |
| Postgres APIs (REST / CLI / SDK) | GA (2026-08-14) | GA | GA |
| Snapshots API and backup schedule API | GA (2026-10-26) | GA | GA |
| Postgres 19 | Supported (2026-11-19) | Supported | Supported |
| Synced tables | GA | — | — |
| LTAP Direct Writes | Beta (2026-08-25) | — | — |
| Lakebase CDF ("Lakehouse sync") | Public Preview (2026-05-12). Was "Lakehouse sync (Beta)" on 2026-03-12. | Public Preview | — |
| Logical replication in and out | Released (2026-10-15), no status label | Released | — |
| Lakebase Search | GA (2026-09-18) | GA | Beta (2026-09-28) |
| system.lakebase telemetry | Beta (2026-09-23) | Beta | — |
| OpenTelemetry export | Beta (2026-04-20) | — | — |
| Insights | Beta | Beta | — |
| Disaster recovery (cross-workspace) | Private Preview (per docs page) | — | — |
| Private Link / PSC | See `networking-security.md` | Inbound Private Link GA (2026-09-28) | PSC Beta (2026-08-22) |
| Bundle `postgres_*` resources | Beta (bundles reference page) | | |

Sources:
- AWS, Azure, and GCP release notes, at the URLs above.
- Synced tables status: https://docs.databricks.com/aws/en/oltp/projects/sync-tables
- Disaster recovery status: https://docs.databricks.com/aws/en/oltp/projects/disaster-recovery
- Bundle resources status: https://docs.databricks.com/aws/en/dev-tools/bundles/resources

## What changed versus the 2026-11-20 starting brief

These differences came out of the verification pass:

- "Lakehouse sync" is now documented as **Lakebase Change Data Feed**, in Public Preview. No current page uses the name "Lakehouse sync".
- Disaster recovery is **Private Preview**, "not intended for production use". It is not GA.
- The Provisioned upgrade "completed in July 2026" per the upgrade page. The bundle and Terraform guides say "Starting June 2026".
- Bundles are now named **Declarative Automation Bundles** ("formerly known as Databricks Asset Bundles").
- The default Postgres version is **18**.
- The docs page for the project-UI assistant calls it "Genie". The release note says "Genie Code".
- Compute sizes: autoscaling goes up to 64 CU, and fixed-size computes go up to 112 CU. Scale-to-zero only works at 32 CU or below.
- Point-in-time queries are done by creating a branch from a past point in time. There is no SQL time-travel syntax.
- GCP's release notes leave out many features that AWS and Azure list.
