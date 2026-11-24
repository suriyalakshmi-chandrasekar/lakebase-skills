# Postgres compatibility

Last verified: 2026-11-20. Check `release-watch.md` first.

## Versions

Sources: https://docs.databricks.com/aws/en/oltp/projects/compatibility and https://docs.databricks.com/aws/en/oltp/projects/postgres-version-support

Supported versions:
- "Lakebase supports Postgres 16, Postgres 17, Postgres 18, and Postgres 19. Postgres 18 is the default version."
- Postgres 19 was added on 2026-11-19, starting with 19.0. It is available on all three clouds.
- The latest minor versions as of November 2026 are 19.0, 18.7, 17.12, and 16.16.

Minor versions:
- "Lakebase runs the latest Postgres minor release for each supported major version and updates it for you."
- "You cannot pin an earlier minor release or downgrade to a previous one."
- For the update window, see `observability-operations.md`.

Major versions:
- "Lakebase does not upgrade a project to a new major Postgres version in place."
- To move to a new major version, create a new project and use `pg_dump`/`pg_restore`.

Postgres 19 limitations:
- `wal2json` replication slots are not supported. Use `pgoutput`.
- `pg_graphql` and `pg_jsonschema` are not available.
- `pg_stash_advice` stashes are not preserved across compute restarts.

> NOTE: an older release note, dated 2026-06-18, says "Postgres 17 remains the default version". The current pages say 18 is the default.

## Extensions

Source: https://docs.databricks.com/aws/en/oltp/projects/extensions

Install, upgrade, and dependencies:
- Install an extension with `CREATE EXTENSION <name>;`. Add `CASCADE` to install its dependencies too.
- Upgrade with `ALTER EXTENSION <name> UPDATE;`. A new version is available only after the compute restarts.
- `pg_uuidv7` is not available. On Postgres 18 and later, use the built-in `uuidv7()`.

The table below was copied from the docs table as the fetch tool rendered it. Spot-check the page if an exact version matters.

| Extension | PG16 | PG17 | PG18 | PG19 |
|---|---|---|---|---|
| address_standardizer / _data_us | 3.3.10 | 3.5.7 | 3.6.4 | 3.7 |
| autoinc | 1.0 | 1.0 | 1.0 | 1.0 |
| bloom | 1.0 | 1.0 | 1.0 | 1.0 |
| btree_gin | 1.3 | 1.3 | 1.3 | 1.4 |
| btree_gist | 1.7 | 1.7 | 1.8 | 1.9 |
| citext | 1.6 | 1.6 | 1.8 | 1.8 |
| cube | 1.5 | 1.5 | 1.5 | 1.5 |
| databricks_auth | 1.0 | 1.0 | 1.0 | 1.0 |
| dict_int | 1.0 | 1.0 | 1.0 | 1.0 |
| earthdistance | 1.2 | 1.2 | 1.2 | 1.2 |
| fuzzystrmatch | 1.2 | 1.2 | 1.2 | 1.2 |
| hll | 2.21 | 2.21 | 2.21 | 2.21 |
| hstore | 1.8 | 1.8 | 1.8 | 1.8 |
| insert_username | 1.0 | 1.0 | 1.0 | 1.0 |
| intagg | 1.1 | 1.1 | 1.1 | 1.1 |
| intarray | 1.5 | 1.5 | 1.5 | 1.5 |
| isn | 1.2 | 1.2 | 1.3 | 1.3 |
| lo | 1.1 | 1.1 | 1.2 | 1.2 |
| ltree | 1.2 | 1.3 | 1.3 | 1.3 |
| moddatetime | 1.0 | 1.0 | 1.0 | 1.0 |
| pg_graphql | 1.5.11 | 1.5.11 | 1.5.12 | Not available |
| pg_hint_plan | 1.6.0 | 1.7.0 | 1.8.0 | 1.9.0 |
| pg_jsonschema | 0.3.3 | 0.3.3 | 0.3.4 | Not available |
| pg_prewarm | 1.2 | 1.2 | 1.2 | 1.2 |
| pg_stash_advice | Not available | Not available | Not available | 1.0 |
| pg_stat_statements | 1.10 | 1.11 | 1.12 | 1.13 |
| pg_trgm | 1.6 | 1.6 | 1.6 | 1.6 |
| pgcrypto | 1.3 | 1.3 | 1.4 | 1.4 |
| pgrouting | 3.4.2 | 3.6.2 | 3.8.0 | 4.0.2 |
| pgrowlocks | 1.2 | 1.2 | 1.2 | 1.2 |
| pgstattuple | 1.5 | 1.5 | 1.5 | 1.5 |
| plpgsql | 1.0 | 1.0 | 1.0 | 1.0 |
| postgis, postgis_raster, postgis_sfcgal, postgis_topology | 3.3.10 | 3.5.7 | 3.6.4 | 3.7.0 |
| postgis_tiger_geocoder | 3.3.10 | 3.5.7 | 3.6.4 | 2025.2 |
| refint | 1.0 | 1.0 | 1.0 | 1.0 |
| seg | 1.4 | 1.4 | 1.4 | 1.4 |
| tablefunc | 1.0 | 1.0 | 1.0 | 1.0 |
| tcn | 1.0 | 1.0 | 1.0 | 1.0 |
| tsm_system_rows | 1.0 | 1.0 | 1.0 | 1.0 |
| tsm_system_time | 1.0 | 1.0 | 1.0 | 1.0 |
| unaccent | 1.1 | 1.1 | 1.1 | 1.1 |
| uuid-ossp | 1.1 | 1.1 | 1.1 | 1.1 |
| vector (pgvector) | 0.8.7 | 0.8.7 | 0.8.7 | 0.8.7 |
| xml2 | 1.1 | 1.1 | 1.2 | 1.2 |
| lakebase_text * | 0.1.3 | 0.1.3 | 0.1.3 | 0.1.3 |
| lakebase_tokenizer * | 0.2.1 | 0.2.1 | 0.2.1 | 0.2.1 |
| lakebase_vector * | 1.1.2 | 1.1.2 | 1.1.2 | 1.1.2 |

\* Available only when Lakebase Search is enabled. See `lakebase-search.md`.

Specific checks:
- `pg_trgm`, `hll`, `vector` (pgvector), and `postgis` are all in the table above.
- Full-text search with `tsvector`/`tsquery` is built into Postgres, not an extension. The Lakebase docs show `to_tsvector`, `to_tsquery`, `plainto_tsquery`, `@@`, and GIN indexes in use (https://docs.databricks.com/aws/en/oltp/projects/lakebase-tokenizer). The Postgres reference is https://www.postgresql.org/docs/current/textsearch.html.

> UNVERIFIED: no Lakebase page explicitly states "built-in full-text search is supported". Support is inferred from the documented examples.

Other extensions:
- `wal2delta` powers Lakebase CDF. See `lakebase-to-delta.md`.
- `pgaudit` is used for HIPAA audit logging. See `networking-security.md`.
- Neither is listed in the user-installable table.

## Unsupported features and limitations

Source: https://docs.databricks.com/aws/en/oltp/projects/compatibility

Superuser and host access:
- "You can't connect using Postgres `superuser`."
- Features that need superuser or local filesystem access are not allowed. `databricks_superuser` takes the place of superuser.
- You have no access to the host operating system.

Parameters:
- You can set only parameters with `user` context, at the session, database, or role level.
- "You cannot configure parameters at the instance level."
- To list the parameters you can set, run `SELECT name FROM pg_settings WHERE context = 'user';`.

Storage and logs:
- `CREATE TABLESPACE` returns an error.
- "Access to Postgres logs is not supported." Logs are available through the system tables instead. See `observability-operations.md`.

Unlogged and temporary tables:
- These use compute-local storage.
- Unlogged tables are lost on restart or scale-to-zero.
- Temporary space is 20 GiB or 15 GiB × the max compute size, whichever is larger.

What scale-to-zero resets:
- It drops session state: temp tables, prepared statements, advisory locks, and LISTEN/NOTIFY.
- `pg_stat_statements` data is reset on scale-to-zero or restart.

Encoding and collation:
- The default is `C.UTF-8`. ICU collations are supported.

Logical replication:
- Native logical replication is supported. See `logical-replication.md`.
