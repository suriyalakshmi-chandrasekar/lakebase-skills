# Lakebase Search (lakebase_vector, lakebase_text, lakebase_tokenizer)

Last verified: 2026-11-20. Check `release-watch.md` first.

## Status

| Cloud | Status | Source |
|---|---|---|
| AWS, Azure | "Lakebase Search is generally available" (2026-09-18). Earlier: Beta (2026-06-16). | https://docs.databricks.com/aws/en/release-notes/lakebase/ |
| GCP | "Lakebase Search is available on GCP (Beta)" (2026-09-28). No GA entry. | https://docs.databricks.com/gcp/en/release-notes/lakebase/ |

> CONFLICT (cross-cloud): Lakebase Search is GA on AWS and Azure but Beta on GCP.

The Search pages themselves carry no status label.

## Overview

Source: https://docs.databricks.com/aws/en/oltp/projects/lakebase-search

Lakebase Search adds hybrid vector and keyword search through three extensions:

| Extension | Purpose | Index type |
|---|---|---|
| `lakebase_vector` | Vector search | `lakebase_ann` |
| `lakebase_text` | BM25 keyword search | `lakebase_bm25` |
| `lakebase_tokenizer` | Tokenization | none |

Requirements:
- Postgres 16 or later.
- In project Settings, go to Lakebase Search and click **Enable Lakebase Search**.
  - Enabling restarts all computes, which drops connections.
  - It "Cannot be turned off once enabled".

Install the extensions:

```sql
CREATE EXTENSION IF NOT EXISTS lakebase_vector CASCADE;   -- installs pgvector as a dependency
CREATE EXTENSION IF NOT EXISTS lakebase_text;
CREATE SCHEMA IF NOT EXISTS tokenizer_ext;
CREATE EXTENSION IF NOT EXISTS lakebase_tokenizer WITH SCHEMA tokenizer_ext;
```

Versions in the extensions table (the same on Postgres 16–19):

| Extension | Version |
|---|---|
| `lakebase_text` | 0.1.3 |
| `lakebase_tokenizer` | 0.2.1 |
| `lakebase_vector` | 1.1.2 |

Source: https://docs.databricks.com/aws/en/oltp/projects/extensions

## lakebase_vector

Source: https://docs.databricks.com/aws/en/oltp/projects/lakebase-vector

It is "a drop-in companion to pgvector". It uses the same vector types, distance operators, and query syntax.

Create an index:

```sql
CREATE INDEX <INDEX_NAME> ON <TABLE> USING lakebase_ann (<VECTOR_COLUMN> vector_l2_ops);
CREATE INDEX ON <TABLE> USING lakebase_ann (<VECTOR_COLUMN> vector_l2_ops) WITH (build_mode = 'standard');
```

Operator classes and query operators:

| Operator class | Operator | Distance |
|---|---|---|
| `vector_l2_ops` | `<->` | L2 |
| `vector_ip_ops` | `<#>` | Negative inner product |
| `vector_cosine_ops` | `<=>` | Cosine |

Index options:
- `build_mode`:
  - `'standard'` is the default.
  - Use `'quality'` only for tables of up to 50 million vectors.
  - `'fast'` is kept for backward compatibility.
- `lists`: defaults to `'auto'`.

Building and rebuilding:
- Use `CREATE INDEX CONCURRENTLY` and `REINDEX INDEX CONCURRENTLY`.

Settings (GUCs):
- `lakebase_ann.probes` (default `'auto'`)
- `lakebase_ann.epsilon` (default `'auto'`)
- `lakebase_ann.prefilter` (default `off`)

Functions:
- `lakebase_ann_prewarm(regclass, scope)`
- `lakebase_ann_index_info(regclass)`
- `lakebase_ann_advise`, `lakebase_ann_tune`, `lakebase_ann_latency`, and `lakebase_ann_sample`. These four need version 1.1.2 or later.

Claims the docs make:
- "indexes over 1 billion vectors on a single index"
- "50-100x faster than HNSW"

## lakebase_text (BM25)

Source: https://docs.databricks.com/aws/en/oltp/projects/lakebase-text

It is "compatible with PostgreSQL's standard tsvector type and query operators".

Create an index:
- Build the index on a populated table.
- The default operator class is `tsvector_bm25_ops`.

```sql
CREATE INDEX <INDEX_NAME> ON <TABLE> USING lakebase_bm25 (<TSVECTOR_COLUMN>);
SELECT id, <TSVECTOR_COLUMN> <@> to_bm25query(to_tsvector('english', '<QUERY>'), '<INDEX_NAME>') AS score
FROM <TABLE> ORDER BY score LIMIT 5;
```

Querying:
- `<@>` returns a negative BM25 score, so sort in ascending order.
- A scan may leave out rows whose score is exactly 0.0.

Index parameters (set with `WITH` or `ALTER INDEX ... SET`):

| Parameter | Default | Range |
|---|---|---|
| `k1` | 1.2 | 1.2–2.0 |
| `b` | 0.75 | 0.0–1.0 |
| `default_limit` | 1000 | 1–65535 |
| `prefilter` | false | |

Settings (GUCs):
- `lakebase_bm25.default_limit`
- `lakebase_bm25.prefilter`
- `lakebase_bm25.enable_scan`

Index statistics:
- BM25 statistics are computed when the index is built and updated by VACUUM.
- They are not MVCC-versioned.
- The docs recommend `ALTER TABLE ... SET (autovacuum_vacuum_insert_scale_factor = 0);` for search tables.

Upgrading:
- Run `ALTER EXTENSION lakebase_text UPDATE`, then `REINDEX INDEX CONCURRENTLY`.

## lakebase_tokenizer

Source: https://docs.databricks.com/aws/en/oltp/projects/lakebase-tokenizer

The tokenizer works through the text-search dictionary interface. Its output is a standard `tsvector`, which you can use with GIN or `lakebase_bm25` indexes.

Templates:
- `tokenizer_wholeword`
- `tokenizer_morph`

CJK support:
- "Version 0.2.0 adds the tokenizer_morph template and the built-in CJK configurations".
- The release note for this is dated 2026-10-15.

Built-in configurations:

| Configuration | Mode | Engine |
|---|---|---|
| `tokenizer_chinese` | mixed | Lindera with Jieba |
| `tokenizer_japanese` | discard | IPADIC |
| `tokenizer_korean` | discard | MeCab KoDic |

`tokenizer_morph` options:
- `Language` (required)
- `Mode`: `none`, `discard`, or `mixed`. Which modes are allowed depends on the language.
- `Normalize`: default `NFKC`.
- `Lowercase`
- `Stemmer`

`tokenizer_wholeword` options:
- `Lowercase`
- `Normalize`: default `none`.
- `EnglishPossessive`
- `StripAccents`
- `Stopwords`
- `Synonyms`
- `Stemmer`: `english`, using Snowball 3.1.0.

Example:

```sql
CREATE TEXT SEARCH DICTIONARY <DICT_NAME> (TEMPLATE = tokenizer_ext.tokenizer_wholeword,
  Lowercase = 'true', StripAccents = 'true', Stemmer = 'english');
SELECT to_tsvector('tokenizer_ext.tokenizer_chinese', <TEXT_COLUMN>) FROM <TABLE>;
```

Limits:

| Item | Limit |
|---|---|
| Stopword or synonym set name | 256 bytes |
| Words and synonyms | 1024 bytes |
| Rows per set | 100,000 |
| Parser token | 2046 bytes (longer tokens are skipped with a NOTICE) |

Phrase queries:
- `mixed` mode can break `<->` phrase queries.
- For position-based queries, use `none` or `discard`.

## Sources of data

Synced tables can feed search:
- Map embeddings to `vector(n)` with a type override.
- Or generate a `tsvector` column.

See `synced-tables.md`.

> UNVERIFIED: overall limits for Lakebase Search. The docs have no single limits page for it.
