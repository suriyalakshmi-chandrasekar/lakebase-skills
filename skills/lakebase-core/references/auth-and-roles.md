# Authentication and authorization

Last verified: 2026-11-20. Check `release-watch.md` first.

Lakebase has two separate permission layers, and nothing syncs them:

- **Platform layer: project ACLs.** These control who can see and manage a project.
- **Postgres layer: roles and GRANTs.** These control what a login can do inside the database.

"These systems have no automatic synchronization." Source: https://docs.databricks.com/aws/en/oltp/projects/manage-project-permissions

## Authentication methods

Source: https://docs.databricks.com/aws/en/oltp/projects/authentication

There are two methods: OAuth tokens, which use a Databricks identity, and native Postgres passwords.

### OAuth tokens

How long tokens last:
- "OAuth tokens expire after one hour."
- Expiry is checked only at login. Connections that are already open stay up.

Rules:
- Tokens are scoped to a workspace, so use one from the project's workspace.
- The connection must use SSL.
- Tokens don't work with the PgBouncer pooler.

Generate a token:

```bash
databricks postgres generate-database-credential projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID> --output json
# The response contains "token" and "expire_time". Use the token as the password.
```

```python
from databricks.sdk import WorkspaceClient
w = WorkspaceClient()   # for M2M: WorkspaceClient(host=..., client_id=..., client_secret=...)
cred = w.postgres.generate_database_credential(
    endpoint="projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID>")
# cred.token, cred.expire_time
```

- Java: `w.postgres().generateDatabaseCredential(new GenerateDatabaseCredentialRequest().setEndpoint("..."))`
- REST: `POST /api/2.0/postgres/credentials`. Source: https://docs.databricks.com/api/postgres/v1/postgres
- UI: Connect → OAuth role → **Copy OAuth token**. This only works for the identity you're logged in as.

Refreshing tokens:
- "Check the expiration time of the OAuth token on each use and refresh when needed." A background refresh thread also works.
- The docs' SQLAlchemy example refreshes when the token is within 2 minutes of expiry.
- Full rotation examples: https://docs.databricks.com/aws/en/oltp/projects/authentication#token-rotation-examples

### Native Postgres passwords (off by default for new projects)

Default:
- "Password connections are disabled by default for new Lakebase projects. Existing projects are not affected by this default."
- This changed on 2026-05-21, on AWS and Azure.
- Sources: https://docs.databricks.com/aws/en/oltp/projects/manage-roles and https://docs.databricks.com/aws/en/release-notes/lakebase/

Turn passwords on for a project:
- UI: Settings → Database connections → **Password (Native Postgres roles)**. You can also set it per compute.
- CLI:
  ```
  databricks postgres update-project projects/<PROJECT_ID> spec.enable_pg_native_login --json '{"spec": {"enable_pg_native_login": true}}'
  ```
- REST: `PATCH /api/2.0/postgres/projects/<PROJECT_ID>?update_mask=spec.enable_pg_native_login` with the body `{"spec": {"enable_pg_native_login": true}}`
- Terraform and bundles: `spec.enable_pg_native_login`

Password rules:
- At least 12 characters, with lowercase, uppercase, a number, and a symbol.
- Passwords are checked for 60-bit entropy.
- "Passwords do not expire automatically."
- Passwords are stored as SCRAM-SHA-256.

Features that need password roles:
- PgBouncer pooling
- Lakebase as a logical-replication publisher. The subscriber connects with a password role.

## Postgres roles

Sources: https://docs.databricks.com/aws/en/oltp/projects/postgres-roles and https://docs.databricks.com/aws/en/oltp/projects/manage-roles

### OAuth roles (map Databricks identities to Postgres)

The project owner's OAuth role is created automatically. Create others in one of these ways.

**SQL.** You need CREATE and CREATE ROLE on the database. "Native Postgres authenticated sessions cannot create OAuth roles."

```sql
CREATE EXTENSION IF NOT EXISTS databricks_auth;            -- once per database
SELECT databricks_create_role('<USER_EMAIL>', 'USER');
SELECT databricks_create_role('<SP_APPLICATION_ID>', 'SERVICE_PRINCIPAL');
SELECT databricks_create_role('<WORKSPACE_GROUP_NAME>', 'GROUP');   -- case-sensitive
```

These roles can only log in. Add grants separately.

**CLI.**

```
databricks postgres create-role projects/<PROJECT_ID>/branches/<BRANCH_ID> --role-id <ROLE_ID> --json '{"spec": {"identity_type": "USER", "postgres_role": "<USER_EMAIL>"}}'
```

**REST.** `POST /api/2.0/postgres/projects/<PROJECT_ID>/branches/<BRANCH_ID>/roles`. This is a long-running operation.

**UI.** Roles & Databases → Add role → OAuth tab.

UI and REST role creation were added on 2026-03-12, on AWS and Azure.

Group roles:
- Any direct or indirect member of the group can log in as the group role with their own token.
- Membership is checked when the member logs in.
- Only workspace-level groups are supported.

If an identity is renamed, its grants break. Drop the role and recreate it.

### Native password roles

- SQL: `CREATE ROLE <ROLE> WITH LOGIN PASSWORD '<PASSWORD>';`. This needs CREATEROLE.
- UI: Add role → Password tab. The password is shown once.
- Creating a role through the SDK, REST, or CLI does not return a password. Use SQL, or **Reset password** in the UI.
- Reset with SQL: `ALTER USER <ROLE> WITH PASSWORD '<NEW_PASSWORD>';`

### Built-in and system roles

- The project owner role is a member of `databricks_superuser` and owns `databricks_postgres`.
- `databricks_superuser` is NOLOGIN. It "should not be used in automated applications".
- Other system roles: `cloud_admin`, `databricks_control_plane`, `databricks_monitor`, `databricks_replicator`, `databricks_writer_<dbid>`, `databricks_reader_<dbid>`, `databricks_gateway`.
- Roles created in the Lakebase UI get `databricks_superuser` privileges. Source: https://docs.databricks.com/aws/en/oltp/projects/manage-projects
- You can't connect as the Postgres `superuser`. Source: https://docs.databricks.com/aws/en/oltp/projects/compatibility

### Other role facts

- Role names can be up to 63 characters.
- After you create a branch, roles on each branch change independently.
- `DROP ROLE` fails if the role owns objects. Reassign them first. The API's DELETE accepts `reassign_owned_to`.

## Grants inside Postgres

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-roles-permissions

"By default, a newly created Postgres role has no database permissions."

```sql
GRANT USAGE ON SCHEMA <SCHEMA> TO "<ROLE>";
GRANT SELECT ON ALL TABLES IN SCHEMA <SCHEMA> TO "<ROLE>";
GRANT INSERT, UPDATE, DELETE ON TABLE <SCHEMA>.<TABLE> TO "<ROLE>";
ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA> GRANT SELECT ON TABLES TO "<ROLE>";
```

- If you grant to a group role, its members inherit the grant.
- To check access, use `has_table_privilege(...)` or `has_database_privilege('<ROLE>', 'databricks_postgres', 'CONNECT')`.

## Project permissions (platform ACLs)

Source: https://docs.databricks.com/aws/en/oltp/projects/manage-project-permissions

| Level | Meaning |
|---|---|
| CAN CREATE | "View and create project resources" |
| CAN USE | "View and use project resources (connect, list, view) without creating or managing them" |
| CAN MANAGE | "Full control over project configuration and resources" |

Defaults:
- Workspace users get CAN CREATE.
- The project owner and workspace admins get CAN MANAGE.

To grant access in the UI, go to Settings → Project permissions. Only CAN MANAGE holders can grant.

Programmatic grants: https://docs.databricks.com/aws/en/oltp/projects/grant-permissions-programmatically

Databricks Apps resource permission value: `CAN_CONNECT_AND_CREATE`. Source: https://docs.databricks.com/aws/en/dev-tools/bundles/resources

> NOTE: the same page writes the permission levels two ways. The table uses spaces ("CAN MANAGE"). The workspace section uses underscores (`CAN_MANAGE`, `CAN_USE`, `CAN_CREATE`).
