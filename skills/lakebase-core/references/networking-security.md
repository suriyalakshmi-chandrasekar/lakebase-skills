# Networking and security

Last verified: 2026-11-20. Check `release-watch.md` first. AWS and Azure facts are kept separate here. GCP coverage is limited.

## Private connectivity

| Cloud | What the docs say | Source |
|---|---|---|
| AWS | "If your workspace uses Private Link, Lakebase requires inbound Private Link. Postgres clients connecting from outside the workspace also require inbound Private Link for performance-intensive services." | https://docs.databricks.com/aws/en/oltp/projects/data-protection |
| Azure | "Inbound Private Link is required." Service Direct Private Link on port 5432 is required only when apps connect from outside the workspace.<br>The Postgres host pattern is `*.database.<region>.azuredatabricks.net`.<br>These don't need the 5432 endpoint: Databricks Apps, Feature Store connectors, the SQL Editor, the Tables editor, and the Data API.<br>Inbound Private Link for Lakebase became GA on 2026-09-28. | https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/private-link |
| GCP | Private Service Connect for Lakebase: **Beta**, released 2026-08-22. | https://docs.databricks.com/gcp/en/release-notes/lakebase/ |

> UNVERIFIED: the AWS Private Link setup steps. The URL https://docs.databricks.com/aws/en/oltp/projects/private-link returned the Data protection page content when fetched. Check that page in a browser.

## IP access and public access

- If you use a client-side firewall, allowlist the Lakebase IPs. Source: https://docs.databricks.com/aws/en/oltp/projects/connect
- For logical replication:
  - When Lakebase is the publisher, the workspace IP access list governs inbound connections.
  - When Lakebase is the subscriber, account network policies govern outbound connections.
  - Source: https://docs.databricks.com/aws/en/oltp/projects/logical-replication
- Features that use the public network: logical replication ("Private Link is not supported for either direction") and disaster recovery replication.

> UNVERIFIED: whether there is a Lakebase-specific IP access list or a switch to disable public access. Neither was found in the docs.

## Encryption

- In transit: all connections must use TLS. Source: https://docs.databricks.com/aws/en/oltp/projects/connection-strings
- Under HIPAA, Databricks provides "Encryption of data at rest and in transit." Source: https://docs.databricks.com/aws/en/oltp/projects/hipaa-compliance

> UNVERIFIED: the default encryption at rest, and the TLS versions and ciphers. Neither is stated on the Lakebase pages.

## Customer-managed keys (CMK)

CMK was released on 2026-04-14 and became available in all regions on 2026-05-20, on AWS and Azure. Source: https://docs.databricks.com/aws/en/release-notes/lakebase/

| | AWS | Azure |
|---|---|---|
| Tier | "The workspace must be on the Enterprise tier." | "Premium plan" |
| Setup | Workspace-level CMK, use case **Managed services**, set in the Account Console | Key Vault software keys or HSM keys, for managed services |
| Source | https://docs.databricks.com/aws/en/oltp/projects/customer-managed-keys | https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/customer-managed-keys |

Both clouds:
- CMK applies only to new projects created after CMK support reached the region.
- You can't convert an existing project in place.
- The project status shows one of: **Active**, **Not configured**, **Not supported**, or **Key unreachable**.
- Rotation: "When your workspace admin rotates the key in your cloud KMS, Lakebase projects are not affected."
- Revocation:
  - Projects become unavailable.
  - Running computes stop.
  - You can't create new projects.
  - A banner says "Database projects unavailable due to key access issue."

## Compliance standards

| | AWS | Azure |
|---|---|---|
| Enabled by default on compliance security profile workspaces with standard | HIPAA, C5, TISAX, or None | HIPAA, PCI-DSS, HITRUST, C5, TISAX, ISMAP, or None |
| PCI-DSS / HITRUST | "supported in all AWS regions where Lakebase is available" | In the default list |
| Region-limited | CCCS Medium (ca-central-1)<br>IRAP (ap-southeast-2)<br>ISMAP (ap-northeast-1)<br>UK Cyber Essentials Plus (eu-west-1, eu-west-2) | CCCS Medium (canadacentral)<br>IRAP (australiaeast)<br>UK Cyber Essentials Plus (uksouth, ukwest) |
| SOC 2 | "Lakebase is SOC 2 Type 2 compliant." | Same |
| Others | "Other compliance standards are not supported." | Same |
| Source | https://docs.databricks.com/aws/en/oltp/projects/data-protection | https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/data-protection |

> CONFLICT (cross-cloud): the two clouds list different standards that are enabled by default. This is recorded as it appears, not merged.

> UNVERIFIED: GCP compliance support.

HIPAA details (source: https://docs.databricks.com/aws/en/oltp/projects/hipaa-compliance):
- The setting can take up to 10 minutes to reach Lakebase.
- Running projects must restart before they enforce HIPAA audit logging.
- Keep protected health information out of object names, query text, and support tickets.
- A Business Associate Agreement (BAA) is required.

## Audit logging

Source: https://docs.databricks.com/aws/en/oltp/projects/hipaa-audit-logging

Scope:
- "HIPAA is the only compliance profile that enables extended audit logging for Lakebase."
- There are three log types: console, API, and Postgres (pgaudit).

HIPAA pgaudit settings (fixed):
- `pgaudit.log` = `all, -misc`
- `pgaudit.log_parameter` = `off`
- `pgaudit.log_catalog` = `off`

Where events go:
- Events land in `system.access.audit` with `service_name = 'lakebase'`.
- `action_name` has the form `<class>.<command>`, for example `ddl.create_table`.
- The audit table keeps records "for 395 days by default."

```sql
SELECT event_time, user_identity.email AS user_email, action_name, request_params
FROM system.access.audit
WHERE service_name = 'lakebase' AND event_date >= current_date() - INTERVAL 7 DAYS
ORDER BY event_time DESC;
```

> UNVERIFIED: which Lakebase audit events non-HIPAA workspaces receive, and audit details on Azure and GCP.
