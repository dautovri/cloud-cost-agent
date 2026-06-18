# cloud-cost-agent — repo guide

This repo is a **Claude Code plugin** that ships a single portable agent skill for multi-cloud FinOps.

## Layout
- `.claude-plugin/plugin.json` — plugin manifest (name, version, author).
- `.claude-plugin/marketplace.json` — lets users `/plugin marketplace add dautovri/cloud-cost-agent`.
- `skills/cloud-cost-agent/SKILL.md` — the skill itself. This is the product; everything else supports it.
- `skills/cloud-cost-agent/docs/` — per-provider setup + IAM policy, shipped alongside the skill.
- `install.sh` — fallback installer for non-Claude agents (Cursor, Gemini, Grok) and curl-pipe installs.
- `README.md` / `PRODUCT.md` — user-facing docs and product vision.

## Conventions
- The skill must stay **portable**: standard SKILL.md frontmatter (`name`, `description`, `allowed-tools`) so it also loads in Cursor/Gemini/Grok. Don't add Claude-only frontmatter keys.
- **Native tools only** — every command uses the provider's own CLI (`aws`, `gcloud`, `az`). No third-party SDKs or services.
- **Read-only first, confirm before changes.** Cost commands must not mutate infrastructure without explicit user confirmation.
- Keep shell snippets **portable** (GNU + BSD `date`) and copy-paste-able.
- Bump `version` in `plugin.json` when the skill changes materially.
