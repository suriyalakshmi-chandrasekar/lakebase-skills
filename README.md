# Lakebase Skills

[Agent Skills](https://agentskills.io/specification) are folders of instructions, scripts, and resources that an AI agent loads when it needs them. This repo holds skills that make an agent an expert on **Databricks Lakebase** (Lakebase Postgres), the managed Postgres OLTP database in Databricks.

Every fact in the skills was taken from official documentation, and each one sits next to its source URL. The sources are:

- docs.databricks.com
- learn.microsoft.com/azure/databricks
- the Databricks Terraform provider docs
- postgresql.org

## Skills

| Skill | What it covers |
|---|---|
| [`lakebase-core`](skills/lakebase-core/SKILL.md) | Lakebase only. It covers: <ul><li>concepts and the legacy Provisioned upgrade</li><li>provisioning (UI, CLI, REST, SDK, Terraform, bundles)</li><li>branching and recovery</li><li>high availability and read replicas</li><li>connectivity and the Data API</li><li>authentication and roles</li><li>networking and security</li><li>Unity Catalog</li><li>synced tables</li><li>Lakebase Change Data Feed</li><li>logical replication</li><li>Lakebase Search</li><li>Postgres compatibility</li><li>Apps and AI</li><li>observability</li><li>limits</li><li>billing model</li><li>troubleshooting</li></ul> |

Migrating data from other systems into Lakebase is out of scope here. A separate `lakebase-migration` skill covers it.

## Why I built this

I spent six months (May to October 2026) building production data serving on Lakebase: forward sync with synced tables, reverse sync with Lakebase Change Data Feed, validation, sizing and cost modeling. Lakebase changes almost weekly, and AI agents kept answering from outdated memory. This skill gives an agent the current, cited facts instead.

**Timeline:** Lakebase hands-on work May to Oct 2026; skill written and verified against docs Nov 2026.

## Author

**Suriyalakshmi Chandrasekar**, Technical Lead, Data Engineering. Databricks Certified Data Engineer Professional.
[LinkedIn](https://www.linkedin.com/in/suriyalakshmi-chandrasekar) · I also post Lakebase field notes there, including the *Databricks Lakebase Cookbook*.

## Disclaimer

**This is not an official Databricks product, and Databricks does not endorse it.** The skills summarize public documentation as it stood on the date in each skill's `metadata.last-verified`.

Lakebase changes often. Names, limits, regions, and preview status can all change. Always check answers against the current Databricks docs before relying on them, and test any commands or templates in your own environment first.

## Install

### Claude Code: plugin marketplace

```
/plugin marketplace add suriyalakshmi-chandrasekar/lakebase-skills
/plugin install lakebase@lakebase-skills
```

From a shell, the equivalents are `claude plugin marketplace add suriyalakshmi-chandrasekar/lakebase-skills` and `claude plugin install lakebase@lakebase-skills`. See https://code.claude.com/docs/en/plugin-marketplaces.

### Claude Code: manual

Copy the skill folder into one of these locations (see https://code.claude.com/docs/en/skills):

| Scope | Path |
|---|---|
| Personal (all your projects) | `~/.claude/skills/lakebase-core/` |
| Project (commit it for your team) | `.claude/skills/lakebase-core/` |

```bash
cp -r skills/lakebase-core ~/.claude/skills/
```

### Codex

Codex reads skills from `$HOME/.agents/skills` and from `.agents/skills` in your repository. See https://learn.chatgpt.com/docs/build-skills. Copy or symlink the folder there:

```bash
cp -r skills/lakebase-core ~/.agents/skills/
# or, per repository:
cp -r skills/lakebase-core <REPO>/.agents/skills/
```

You can also install it with the built-in installer:

```
$skill-installer install https://github.com/suriyalakshmi-chandrasekar/lakebase-skills/tree/main/skills/lakebase-core
```

The folder includes optional Codex UI metadata in `agents/openai.yaml`. Restart Codex if the skill does not appear.

### Claude.ai and the Claude API

1. Zip the `skills/lakebase-core` folder, with the folder itself at the root of the zip.
2. Upload it:
   - Claude.ai: go to Settings → Capabilities → Skills. See "Using skills in Claude" on support.claude.com.
   - Claude API: use the Skills API. See https://docs.claude.com/en/api/skills-guide.

## Validate

This repo uses the reference validator from [agentskills/agentskills](https://github.com/agentskills/agentskills/tree/main/skills-ref). Install it from a source checkout, then run it:

```bash
git clone https://github.com/agentskills/agentskills
cd agentskills/skills-ref
uv sync    # or: python -m venv .venv && pip install -e .
source .venv/bin/activate    # Windows: .venv\Scripts\Activate.ps1
skills-ref validate <PATH_TO_REPO>/skills/lakebase-core
```

## Keeping it current

Each skill includes `references/release-watch.md`. It lists the Lakebase release-notes pages for AWS, Azure, and GCP, and the newest entry that was checked.

To list release-note entries newer than the skill's `metadata.last-verified` date, run:

```bash
python skills/lakebase-core/scripts/check_release_notes.py
```

When you update a fact:

1. Update the reference file and its URL.
2. Add the URL to `references/sources.md` with the fetch date.
3. Bump `metadata.last-verified` and `metadata.version` in `SKILL.md`.

## Contributing

Contributions are welcome. Please follow these rules:

- **Official docs only.** Every new or changed fact needs the official doc URL next to it and an entry in `references/sources.md`. Don't add facts from memory, blogs, or forums.
- If you can't find a doc page for something, mark it `> UNVERIFIED: <what to check>` rather than guessing.
- Keep AWS, Azure, and GCP differences separate, and quote preview labels exactly as the docs write them.
- **No prices,** and no client names, people's names, emails, workspace URLs, account IDs, or tokens.
- Keep `SKILL.md` under 500 lines. Put detail in `references/`.
- Run `skills-ref validate` before you open a pull request.

## License

[MIT](LICENSE). The skill content summarizes public Databricks, Microsoft and PostgreSQL documentation; each fact links to its source.
