# Unity Catalog registration and a synced table (Delta -> Lakebase). Replace every <PLACEHOLDER>.
# Field names come from the provider docs (GA), last verified 2026-11-20:
#   https://github.com/databricks/terraform-provider-databricks/blob/main/docs/resources/postgres_synced_table.md
# TRIGGERED and CONTINUOUS need Change Data Feed on the source table.

resource "databricks_postgres_catalog" "this" {
  catalog_id = "<UC_CATALOG_NAME>"
  spec = {
    postgres_database          = "<DATABASE>"
    create_database_if_missing = true
    branch                     = "projects/<PROJECT_ID>/branches/<BRANCH_ID>"
  }
}

resource "databricks_postgres_synced_table" "this" {
  synced_table_id = "<UC_CATALOG_NAME>.<SCHEMA>.<TABLE>"
  spec = {
    source_table_full_name             = "<SRC_CATALOG>.<SRC_SCHEMA>.<SRC_TABLE>"
    primary_key_columns                = ["<PK_COLUMN>"]
    scheduling_policy                  = "SNAPSHOT"   # SNAPSHOT | TRIGGERED | CONTINUOUS
    postgres_database                  = "<DATABASE>"
    branch                             = "projects/<PROJECT_ID>/branches/<BRANCH_ID>"
    create_database_objects_if_missing = true
    new_pipeline_spec = {
      storage_catalog = "<PIPELINE_STORAGE_CATALOG>"
      storage_schema  = "<PIPELINE_STORAGE_SCHEMA>"
    }
  }
  depends_on = [databricks_postgres_catalog.this]
}
