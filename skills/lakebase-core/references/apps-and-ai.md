# Apps and AI integration

Last verified: 2026-11-20. Check `release-watch.md` first.

## Databricks Apps

Source: https://docs.databricks.com/aws/en/oltp/projects/databricks-apps

How it works:
- When you add Lakebase as an app resource, Databricks creates a service principal for the app and a matching Postgres role with full database access.
- The connection details are injected as environment variables, so you don't set up roles by hand.
- To add the resource, go to **App resources** and pick a project, branch, and database.

Schema naming:
- The schema is named `{app-name}_schema_{service-principal-id}`, with hyphens removed from the ID.
- You can't change the app name later.

Other details:
- Templates are available for Dash, Flask, and Streamlit.
- In bundles, the app resource binding uses `postgres:` with `branch`, `database`, and `permission: CAN_CONNECT_AND_CREATE`. Source: https://docs.databricks.com/aws/en/dev-tools/bundles/resources
- The app resource was added on 2026-03-16, on AWS, Azure, and GCP.
- Full guide: https://docs.databricks.com/aws/en/dev-tools/databricks-apps/lakebase

Which way to build an app:
- Databricks Apps is the "Recommended" path.
- The other options are a manual OAuth setup, external apps using the SDK or API, and the Data API as a lightweight option.
- Source: https://docs.databricks.com/aws/en/oltp/projects/build-applications

## Online Feature Store and Model Serving

Source: https://docs.databricks.com/aws/en/oltp/projects/feature-store

How it works:
- Databricks Online Feature Stores are powered by Lakebase.
- When you create an online store with the Feature Engineering client, it provisions a Lakebase project.

Publish modes:
- TRIGGERED (the default)
- CONTINUOUS
- SNAPSHOT

Limitations:
- `update_online_store` doesn't support Lakebase projects created in the Lakebase UI or through the Projects API.
- Feature Serving or Model Serving endpoints that look up several online stores still work. You can't create new setups like that on Lakebase.
- Details: https://docs.databricks.com/aws/en/machine-learning/feature-store/online-feature-store#limitations

> UNVERIFIED: the full limitations list on the online-feature-store page. It wasn't fetched.

## Agents: state and memory

Source: https://docs.databricks.com/aws/en/oltp/projects/state-management

Lakebase can store agent memory:
- Short-term memory: thread IDs and checkpoints.
- Long-term memory.

Supported deployment targets:
- Databricks Apps, using LangGraph checkpointers or the OpenAI Agents SDK.
- Model Serving, using Lakebase-backed checkpoints.

Related guides:
- https://docs.databricks.com/aws/en/agents/agent-memory/managed-memory
- https://docs.databricks.com/aws/en/agents/custom-agents/model-serving/stateful-agents-model-serving

For hybrid vector and keyword retrieval, see `lakebase-search.md`.

## Genie in the Lakebase project UI

Source: https://docs.databricks.com/aws/en/oltp/projects/lakebase-genie

How it works:
- Describe a problem in plain language. Genie reads `system.lakebase` telemetry and the project configuration to investigate.
- Genie asks for your approval before each action, including investigative queries. Any fix needs explicit confirmation.
- Genie can act on Insights findings ("Fix with Genie"). See `observability-operations.md`.

Limitations:
- Customizations, Automations, Spaces, and Add context appear in the UI but have no effect in Lakebase.
- Branches and endpoints show up by internal ID.

> NOTE: the release notes for 2026-08-24 (AWS and Azure) say "Genie Code in the Lakebase project UI". The docs page calls the feature only "Genie". It carries no status label.
