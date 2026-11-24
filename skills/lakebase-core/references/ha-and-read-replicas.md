# High availability, read replicas, and SLA

Last verified: 2026-11-20. Check `release-watch.md` first.

## High availability (HA)

Sources: https://docs.databricks.com/aws/en/oltp/projects/high-availability and https://docs.databricks.com/aws/en/oltp/projects/manage-high-availability

Size:
- "2 (1 primary, 1 secondary), 3 (1 primary, 2 secondaries), or 4 (1 primary, 3 secondaries) total compute instances". In other words, 1–3 secondaries.
- HA was added on 2026-03-02 on AWS and Azure. The GCP release notes have no entry for it.

Placement and failover:
- Secondaries run in "different availability zones."
- Failover is automatic. "Failover preserves all committed transactions."
- Existing connections are dropped during failover and must reconnect.
- The best-practices table says apps with retry logic "reconnect automatically within seconds."

Prerequisites and constraints:
- Scale-to-zero must be off (`no_suspension: true`).
- The autoscaling range must be 16 CU or less.

Enable through REST:

```
PATCH .../endpoints/<ENDPOINT_ID>?update_mask=spec.group,spec.suspension
{"spec": {"group": {"min": 2, "max": 2, "enable_readable_secondaries": true}, "no_suspension": true}}
```

Terraform equivalent: `group = { min = 2, max = 2, enable_readable_secondaries = true }`. Source: https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_endpoint.md

Reading from secondaries:
- Read traffic goes through the `-ro` connection string. It works only when "Allow access to read-only compute instances" is on.
- The docs recommend two or more readable secondaries. With only one, "all read traffic on the -ro connection string is interrupted during a failover."

Storage:
- "High availability configures compute redundancy only. Lakebase storage is highly available regardless of your HA setting."
- Source: https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/high-availability

> UNVERIFIED: the failover time. No number is documented.

> NOTE: the HA page doesn't say whether replication is synchronous. The DR page's comparison table says HA data loss is "None (RPO = 0), replication is synchronous." Source: https://docs.databricks.com/aws/en/oltp/projects/disaster-recovery

## Read replicas

Source: https://docs.databricks.com/aws/en/oltp/projects/read-replicas

What they are:
- "Read replicas are independent read-only computes." They read the same storage as the primary, and "don't replicate or duplicate data."
- Replication is asynchronous and "eventually consistent."

Limits and features:
- You can have up to 6 read replicas per branch.
- Read replicas support autoscaling and scale-to-zero.
- They have "No additional storage costs."

Create a read replica:
- UI: open the Computes tab and click **Add Read Replica**.
- Terraform: create an endpoint with `endpoint_type = "ENDPOINT_TYPE_READ_ONLY"`.

How they differ from HA secondaries:
- Read replicas don't take part in failover.
- Each read replica has its own endpoint.

Data API:
- Writes to a read replica return HTTP 405 with error code 25006. Source: https://docs.databricks.com/aws/en/oltp/projects/data-api

## SLA

The AWS and Azure docs describe the SLA differently. They are recorded separately here, not merged.

| Cloud | What the docs state | Source |
|---|---|---|
| AWS | Covers all endpoint connection strings "excluding connection strings to secondary compute instances within a high availability endpoint." Unavailability means no successful connection for a one-minute interval. Beta services are excluded. The credit tiers name 99.99%, 99.9%, 99.0%, and 95.0%. No headline uptime figure is stated. | https://docs.databricks.com/aws/en/oltp/projects/high-availability and https://www.databricks.com/legal/sla/lakebase-sla |
| Azure | "Lakebase offers a 99.99% Monthly Uptime Percentage SLA for Lakebase Endpoints configured in zone-redundant high availability mode, and a 99.9% Monthly Uptime Percentage SLA for Single Compute Lakebase Endpoints." | https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/high-availability |
| GCP | Not checked. | — |

> UNVERIFIED: the GCP SLA. Check https://docs.databricks.com/gcp/en/oltp/projects/high-availability
