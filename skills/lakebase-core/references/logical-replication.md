# Native Postgres logical replication (in and out)

Last verified: 2026-11-20. Check `release-watch.md` first.

Sources:
- https://docs.databricks.com/aws/en/oltp/projects/logical-replication
- https://docs.databricks.com/aws/en/oltp/projects/logical-replication-publication
- https://docs.databricks.com/aws/en/oltp/projects/logical-replication-subscription
- https://docs.databricks.com/aws/en/oltp/projects/logical-replication-manage

## Status

- Release notes, 2026-10-15 (AWS and Azure): "You can now use native Postgres logical replication to stream changes into and out of Lakebase."
- There is no entry in the GCP release notes.

> UNVERIFIED: the preview status. No Beta, Preview, or GA label appears on the pages or in the release note.

> Scope note: using replication *to migrate* an external database into Lakebase belongs to the `lakebase-migration` skill. This file covers only the Lakebase-side feature.

## Roles

"Lakebase can act as a subscriber that receives changes from an external publisher, or as a publisher that sends changes to an external subscriber."

Lakebase runs with `wal_level = logical` by default.

## Lakebase as publisher (replicating out)

Requirements:
- Create the publication as a member of `databricks_superuser`, for example the project owner role.
- Password connections must be enabled on the project. They are off by default for new projects.
- The subscriber must connect with a native password role that has the `REPLICATION` attribute.
- Roles created in the Lakebase App, CLI, or API have `REPLICATION`. Roles created with SQL don't. Add it with `ALTER ROLE <ROLE> REPLICATION;`.
- Each table needs a PRIMARY KEY or a replica identity.

Subscriber connection:
- Point the subscriber at the **direct** host, "not the -pooler connection pooler hostname."

Decoder plugins:
- The default is `pgoutput`.
- `wal2json` is also supported, except on Postgres 19.

```sql
-- on Lakebase
CREATE PUBLICATION <PUBLICATION> FOR TABLE <TABLE_1>, <TABLE_2>;
```

## Lakebase as subscriber (replicating in)

Requirements on the source database:
- `wal_level = logical`.
  - Self-managed Postgres: `ALTER SYSTEM SET wal_level = logical;`, set `max_wal_senders` and `max_replication_slots`, then restart.
  - Aurora or RDS: set `rds.logical_replication = 1` and reboot.
- A role with `REPLICATION LOGIN`, plus `USAGE` on the schema and `SELECT` on the tables.
- A publication.
- A public endpoint.

Requirements on Lakebase:
- The role that creates the subscription must be a `databricks_superuser` member, or have both `pg_create_subscription` and `CREATE` on the database.
- "The pg_create_subscription role alone is not enough."
- Create the target tables first. They must be empty and have the same names and columns as the source tables.

```sql
-- on Lakebase
GRANT pg_create_subscription TO <ROLE>;
GRANT CREATE ON DATABASE <DATABASE> TO <ROLE>;
CREATE SUBSCRIPTION <SUBSCRIPTION>
  CONNECTION 'host=<SOURCE_HOST> port=5432 dbname=<SOURCE_DB> user=<REPL_USER> password=<PASSWORD> sslmode=verify-full sslrootcert=system'
  PUBLICATION <PUBLICATION>;
```

Sequences:
- Sequences aren't replicated. Before cutover, set them with `pg_catalog.setval(pg_catalog.pg_get_serial_sequence('<TABLE>', '<COLUMN>'), (SELECT MAX(<COLUMN>) FROM <TABLE>))`.

## What is and isn't replicated

- "Logical replication copies data, not schema. Create target tables before you start replication. Later schema changes are not replicated."
- "Foreign tables are not replicated."

## Limits and behaviour

Slots and senders:
- `max_wal_senders = 10` and `max_replication_slots = 10` on Lakebase. Plan for one of each per subscriber.
- To raise the limits, contact Databricks.
- When Lakebase is the publisher, it removes a slot that has been inactive for "approximately 40 hours".

Where replication runs:
- Replication runs on the primary compute only, not on read replicas.
- Replication between two Lakebase databases in the same region isn't supported. Cross-region replication is supported.

Effect on other features:
- Restoring a branch deletes all replication slots on that branch.
- Child branches don't inherit subscriptions.
- A compute with an active subscriber doesn't scale to zero, which can increase compute usage.

Latency:
- The verify steps say the change appears "within a few seconds". This is not an SLA.

## Networking and TLS

- "Logical replication runs over public networking. Private Link is not supported for either direction."
- Subscriber (Lakebase dialing out): account network policies must allow the destination. If they don't, `CREATE SUBSCRIPTION` fails with "restricted by Account Network Policies."
- Publisher (external subscribers dialing in): governed by the workspace IP access list.
- TLS is enforced. The docs recommend `sslmode=verify-full sslrootcert=system`. Private certificate authorities are not supported.

## Monitoring and cleanup

```sql
SELECT subname, subenabled FROM pg_catalog.pg_subscription;
SELECT subname, received_lsn, latest_end_lsn, last_msg_receipt_time FROM pg_catalog.pg_stat_subscription;
SELECT slot_name, slot_type, active, restart_lsn FROM pg_catalog.pg_replication_slots;
SELECT * FROM pg_catalog.pg_stat_replication WHERE application_name <> 'walproposer';
```

Per-table state is in `pg_subscription_rel.srsubstate`:

| Value | Meaning |
|---|---|
| `i` | initializing |
| `d` | copying data |
| `s` | synchronized |
| `r` | ready |

Lakebase also has internal slots, `wal_proposer_slot` and `wal_retention_slot`. Don't drop them.

Cleanup:
- Run `DROP SUBSCRIPTION <SUBSCRIPTION>;`.
- If the publisher is unreachable, run `ALTER SUBSCRIPTION ... DISABLE;`, then `ALTER SUBSCRIPTION ... SET (slot_name = NONE);`, then `DROP SUBSCRIPTION`. After that, drop the slot on the publisher with `pg_drop_replication_slot`.

> UNVERIFIED: which data types logical replication supports. No list is documented.
