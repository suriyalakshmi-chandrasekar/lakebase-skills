# Connecting: endpoints, TLS, psql, drivers, pooling, SQL Editor, Tables editor, Data API

Last verified: 2026-11-20. Check `release-watch.md` first. Always copy the exact host from the **Connect** dialog, because the hostname format differs between doc examples (see the end of this file).

## Connection strings and TLS

Source: https://docs.databricks.com/aws/en/oltp/projects/connection-strings

Formats:
- OAuth: `postgresql://<IDENTITY>@<HOST>/databricks_postgres?sslmode=require`. The password is the OAuth token.
- Password: `postgresql://<ROLE>:<PASSWORD>@<HOST>/databricks_postgres?sslmode=require`
- Environment variables: `PGHOST`, `PGPORT=5432`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

Host:
- The host uses the compute UID with an `ep-` prefix, not the compute name.
- The port is 5432.

TLS:
- "Lakebase requires that all connections use SSL/TLS encryption. The `sslmode=require` parameter enforces this requirement."
- For logical replication, the docs recommend `sslmode=verify-full sslrootcert=system`. Source: https://docs.databricks.com/aws/en/oltp/projects/logical-replication-subscription

Firewalls:
- If you use a client-side firewall, allowlist the Lakebase IPs listed at https://docs.databricks.com/aws/en/resources/ip-domain-region. Source: https://docs.databricks.com/aws/en/oltp/projects/connect

Timeouts:
- Idle connections time out after 24 hours.
- A connection can live for at most 3 days.
- Source: https://docs.databricks.com/aws/en/oltp/projects/authentication

## psql

Source: https://docs.databricks.com/aws/en/oltp/projects/connect-psql and https://docs.databricks.com/aws/en/oltp/projects/connect-overview

psql 14 or higher is required.

```bash
psql 'postgresql://<ROLE>:<PASSWORD>@<HOST>/databricks_postgres?sslmode=require'
psql -h <HOST> -p 5432 -U <ROLE> -d databricks_postgres
```

Using an OAuth token:
1. Copy the token from Connect → OAuth role → **Copy OAuth token**.
2. Run `export PGPASSWORD='<OAUTH_TOKEN>'`.
3. Connect.

Troubleshooting:
- If psql hangs when you paste a token at the password prompt, use `PGPASSWORD` instead.
- If psql still prompts, run `unset PGSERVICE PGSERVICEFILE`.

## Drivers and frameworks

Source: https://docs.databricks.com/aws/en/oltp/projects/framework-examples

Examples on this page use native password auth:
- SQLAlchemy
- Go (`github.com/lib/pq`)
- Django (`'sslmode': 'require'`)
- .NET (`SSL Mode=Require`)
- Prisma (`DATABASE_URL`)

GUI clients:
- The docs list psql, pgAdmin, DBeaver, and PgHero. Source: https://docs.databricks.com/aws/en/oltp/projects/postgres-clients
- The docs recommend password roles for these tools, because "OAuth tokens expire after one hour".

For OAuth token rotation with psycopg (a connection pool that calls `generate_database_credential` on each new connection) and SQLAlchemy, see https://docs.databricks.com/aws/en/oltp/projects/authentication#token-rotation-examples. More detail is in `auth-and-roles.md`.

JDBC:
- If you see errors about prepared statements, set `prepareThreshold=0`. Source: https://docs.databricks.com/aws/en/oltp/projects/connection-pooling

> UNVERIFIED: Node.js (`pg`) and Java JDBC connection examples. They were not found on the framework-examples page.

## Connection limits

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-computes

| Compute | Approx. RAM | Max connections |
|---|---|---|
| 0.5 CU | ~1 GB | 105 |
| 1 CU | ~2 GB | 218 |
| 2 CU | ~4 GB | 443 |
| 4 CU | ~8 GB | 894 |
| 8 CU | ~16 GB | 1795 |
| 16 CU | ~32 GB | 3597 |
| 24–112 CU | | 3993 |

For an autoscaling compute, the connection limit is set by the smaller of the max CU and 8 × the min CU. For example, a 2–8 CU compute allows 1,795 connections.

`SHOW max_connections` can report a higher number than this table, because some connections are reserved.

## Connection pooling (built-in PgBouncer)

Source: https://docs.databricks.com/aws/en/oltp/projects/connection-pooling

Basics:
- "Lakebase runs PgBouncer in transaction mode". It supports "up to 10,000 concurrent client connections".
- **Pooling requires native Postgres password auth. It is not available for OAuth roles.**
- To turn it on: open Connect, pick a password role, and switch on **Connection pooling**.

Pooled hosts (both on port 5432):
- Read-write: `<endpoint-id>-pooler.<region>.<cloud>.databricks.com`
- Read-only: `<endpoint-id>-ro-pooler.<region>.<cloud>.databricks.com`. This needs an HA endpoint with readable secondaries.

Fixed settings:
- `pool_mode=transaction`
- `max_client_conn=10000`
- `default_pool_size=0.9 * max_connections`
- `max_prepared_statements=1000`
- `query_wait_timeout=120`

There is one pool per user and database pair.

Not supported through the pooler:
- SQL `PREPARE`/`DEALLOCATE`
- Session `SET`. Use `ALTER ROLE ... SET` instead.
- Session temp tables
- `WITH HOLD` cursors
- Advisory locks
- `LISTEN`/`NOTIFY`
- `pg_dump` and schema migrations. Use a direct connection for these.

## SQL Editor

Source: https://docs.databricks.com/aws/en/oltp/projects/sql-editor

To use it, open the Lakebase App, then your project, then **SQL Editor**. Choose a branch and database.

Features:
- `EXPLAIN` and `EXPLAIN (ANALYZE)`. EXPLAIN ANALYZE runs the statement, so DML changes data.
- Export to CSV, JSON, or XLSX.
- Meta-commands: `\dt`, `\d`, `\l`, `\?`, `\h`.
- Role: "By default, the SQL Editor connects as the best available role for you." To override, add `?role=<ROLE>` to the URL.

Limits when public access is disabled (Private Link proxy):
- No transactions
- `SET` applies to a single request only
- No `LISTEN`/`NOTIFY`, no `COPY FROM STDIN`, and no `\watch`
- Results are limited to 32 MB

## Tables editor

Source: https://docs.databricks.com/aws/en/oltp/projects/table-editor

What you can do:
- Add, edit, and delete records
- Filter
- Drop or truncate tables
- Export JSON, CSV, or XLSX
- Manage schemas, views, and enums

Role selection works the same way as in the SQL Editor.

If a preview is larger than 64 MB, you get HTTP 507 "response is too large (max is 67108864 bytes)". Use a Postgres client instead.

## Data API (PostgREST-compatible REST)

Source: https://docs.databricks.com/aws/en/oltp/projects/data-api

What it is:
- "Databricks' implementation designed to be compatible with the PostgREST specification."
- No preview label appears on the page.

Enable it:
- Click **Enable Data API**. This creates the `authenticator` role and the `pgrst` schema, and exposes the `public` schema.

Authentication:
- Every request needs a Databricks OAuth bearer token in the `Authorization` header.
- "The `authenticator` role assumes the identity of the requesting user."
- Don't use the project owner identity. The docs recommend a service principal.

Set up roles **with SQL**. A role created in the UI fails with SQLSTATE 42501 at the `GRANT ... TO authenticator` step.

```sql
CREATE EXTENSION IF NOT EXISTS databricks_auth;
SELECT databricks_create_role('<IDENTITY>', 'USER');   -- or 'SERVICE_PRINCIPAL' with the application ID
GRANT "<IDENTITY>" TO authenticator;
GRANT USAGE ON SCHEMA public TO "<IDENTITY>";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "<IDENTITY>";
```

Requests:

```bash
curl -H "Authorization: Bearer $DBX_OAUTH_TOKEN" "$REST_ENDPOINT/public/<TABLE>?id=gte.2"
```

- Copy `REST_ENDPOINT` from the API tab and append `/public`.
- Filters: `eq`, `gte`, `lte`, `neq`, `like`, `in`. You can also use `select=`, `order=`, `limit`, and `offset`.
- Supported methods: POST, PATCH, and DELETE.

Settings:
- Exposed schemas (default: `public`)
- Max rows
- CORS origins
- OpenAPI at `/openapi.json` (off by default)
- Server-Timing headers

Row-level security:
- `ALTER TABLE <T> ENABLE ROW LEVEL SECURITY;` then `CREATE POLICY ... TO "<IDENTITY>" USING (...)`
- `current_user` returns the user's email.

Not supported:
- JWT configuration
- GUCs
- `db-pre-request`

On Azure, if apps connect only through the Data API, the port-5432 Private Link endpoint isn't needed. Source: https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/private-link

> NOTE: the docs show hostnames in two formats. Some examples use `ep-abc-123.databricks.com`. The SDK examples use `ep-example.database.region.databricks.com`. On Azure, the host pattern is `*.database.<region>.azuredatabricks.net`. Copy the host from the Connect dialog.
