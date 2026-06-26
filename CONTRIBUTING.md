# Contributing to cloud-cost-agent

Thanks for helping improve the skill. It's a single portable agent skill plus per-provider docs — small surface, high bar for correctness.

## What this repo is
A Claude Code plugin shipping `skills/cloud-cost-agent/SKILL.md`. See [CLAUDE.md](./CLAUDE.md) for the layout and conventions.

## Ground rules
- **Native tools only.** Every command must use the provider's own CLI (`aws`, `gcloud`, `az`). No third-party SDKs, services, or data ingestion.
- **Read-only first.** Cost commands must never mutate infrastructure without explicit user confirmation. Don't add a command that deletes/resizes/purchases without an approval step.
- **Verify CLI commands against current docs.** Cloud CLIs change. Before adding or editing a command, confirm the subcommand, required flags, and that it isn't deprecated against the provider's official reference. Cite the doc URL in the PR.
- **Portable shell.** Snippets must run on both GNU and BSD/macOS (e.g. use the portable date helper in SKILL.md, not `date -v`).
- **Least privilege.** Any new API call must be reflected in `docs/iam-readonly-policy.json` (AWS) or the GCP/Azure permission notes.

## Testing a change
1. Install locally: `./install.sh --tool claude` (copies into `~/.claude/skills/`).
2. Restart your agent and run an audit against a real account to confirm the commands work and return data.
3. For doc/setup changes, follow the steps yourself end-to-end.

## Submitting
- Keep PRs focused. One provider or one concern at a time.
- Bump `version` in `.claude-plugin/plugin.json` when the skill changes materially.
- Open an issue first for larger changes (new providers, new sections) so we can align on scope.

## Site
The marketing page lives in `site/` and auto-deploys to GitHub Pages on push to `main`. Keep claims accurate — don't reintroduce "no data leaves your machine" style overclaims (output flows to your LLM provider).
