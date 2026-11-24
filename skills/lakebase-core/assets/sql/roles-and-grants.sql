-- Map Databricks identities to Postgres roles, then grant access. Replace every <PLACEHOLDER>.
-- Syntax comes from these pages, last verified 2026-11-20:
--   https://docs.databricks.com/aws/en/oltp/projects/postgres-roles
--   https://docs.databricks.com/aws/en/oltp/projects/manage-roles-permissions
-- Run this as a role with CREATE and CREATE ROLE, using an OAuth session.
-- A native-password session cannot create OAuth roles.

CREATE EXTENSION IF NOT EXISTS databricks_auth;   -- once per database

SELECT databricks_create_role('<USER_EMAIL>', 'USER');
SELECT databricks_create_role('<SP_APPLICATION_ID>', 'SERVICE_PRINCIPAL');
SELECT databricks_create_role('<WORKSPACE_GROUP_NAME>', 'GROUP');   -- case-sensitive

-- New roles have no database permissions until you grant them
GRANT USAGE ON SCHEMA <SCHEMA> TO "<WORKSPACE_GROUP_NAME>";
GRANT SELECT ON ALL TABLES IN SCHEMA <SCHEMA> TO "<WORKSPACE_GROUP_NAME>";
ALTER DEFAULT PRIVILEGES IN SCHEMA <SCHEMA> GRANT SELECT ON TABLES TO "<WORKSPACE_GROUP_NAME>";
GRANT INSERT, UPDATE, DELETE ON TABLE <SCHEMA>.<TABLE> TO "<SP_APPLICATION_ID>";

-- Native password role (needs CREATEROLE; password login must be turned on for the project)
CREATE ROLE <ROLE_NAME> WITH LOGIN PASSWORD '<STRONG_PASSWORD>';
