"""Connect to Lakebase with a short-lived OAuth token (Databricks SDK + psycopg).

Calls are taken from https://docs.databricks.com/aws/en/oltp/projects/authentication
(last verified 2026-11-20). Tokens expire after one hour and are checked only at login,
so get a new token for each new connection, or refresh it before it expires.
For a production pool, see the token-rotation examples on that page.
Replace every <PLACEHOLDER>. Copy the host from the Connect dialog.
"""
import psycopg
from databricks.sdk import WorkspaceClient

ENDPOINT = "projects/<PROJECT_ID>/branches/<BRANCH_ID>/endpoints/<ENDPOINT_ID>"

w = WorkspaceClient()  # for M2M: WorkspaceClient(host=..., client_id=..., client_secret=...)
credential = w.postgres.generate_database_credential(endpoint=ENDPOINT)

with psycopg.connect(
    host="<HOST_FROM_CONNECT_DIALOG>",
    port=5432,
    dbname="databricks_postgres",
    user="<DATABRICKS_IDENTITY>",   # user email, or service principal application ID
    password=credential.token,
    sslmode="require",
) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version()")
        print(cur.fetchone())
