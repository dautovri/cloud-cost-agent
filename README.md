# cloud-cost-agent

An open-source AI agent skill that finds cloud savings across AWS, GCP, and Azure — using each provider's own recommendation engines, inside the coding agent you already have open. No FinOps SaaS to onboard, no cross-account IAM roles to grant, no billing data leaving your machine.

- **Native APIs, not a wrapper.** Queries Cost Explorer, Compute Optimizer, GCP Recommender, and Azure Advisor directly — no third-party cost model, no custom-discount drift.
- **Zero setup beyond auth.** Uses your existing `aws`, `gcloud`, `az` CLI credentials. Nothing new to provision.
- **Read-only by default.** Audits never mutate infrastructure. Any change requires explicit approval.
- **Ranked output.** Savings sorted by estimated $/month and effort, with the exact next command for each item.
- **Works everywhere.** Claude Code, Cursor, Codex, Gemini CLI, and 70+ other agents via [skills.sh](https://skills.sh).
- **Free.** MIT license. The only cost is the providers' own metered APIs (e.g. AWS Cost Explorer ~$0.01/request).

```
you ▸ audit AWS & GCP, last 30 days, quick wins only

Provider: AWS   potential savings ~$1,910/mo
  ▸ 3× idle EBS volumes (gp2, unattached)      $240/mo  VeryLow
  ▸ Rightsize m5.2xlarge → m5.large (i-0a3f)   $520/mo  Low
  ▸ Compute Savings Plan, 1yr no-upfront        $1,150/mo Low

Provider: GCP   potential savings ~$430/mo
  ▸ Idle VM in us-central1-a (stop/delete)     $180/mo  VeryLow
  ▸ n1-standard-8 → n2-standard-4              $250/mo  Low
```

## Install

**Claude Code** (recommended):

```
/plugin marketplace add dautovri/cloud-cost-agent
/plugin install cloud-cost-agent
```

**Any agent** via npx (Cursor, Codex, Gemini, Copilot + 70 more):

```bash
npx skills add dautovri/cloud-cost-agent
```

**Or the bundled installer** (auto-detects your agent):

```bash
curl -sL https://raw.githubusercontent.com/dautovri/cloud-cost-agent/main/install.sh | bash
```

## Use it

1. Authenticate to the clouds you use: `aws sso login`, `gcloud auth login`, `az login`.
2. Ask your agent:

```
audit my AWS spend last 30 days
find quick wins on GCP and Azure
rightsizing recommendations for all providers
```

The skill picks the right native commands per provider and returns a prioritized savings list with concrete next steps.

## What it queries

| Provider | Native surfaces |
|----------|-----------------|
| **AWS** | Cost Explorer, Compute Optimizer, Cost Optimization Hub |
| **GCP** | Recommender (machine type, idle, CUDs), BigQuery billing export |
| **Azure** | Advisor (Cost category), Cost Management, Consumption |

## What it doesn't do

This is an episodic savings audit, not a continuous monitoring platform. No anomaly alerts, no historical trends, no chargeback, no executive dashboards. If you need those, keep Vantage, CloudZero, or similar — they do a different job, well.

## Links

- **[Website](https://dautovri.github.io/cloud-cost-agent/)** — product page with full comparison and FAQ
- **[SKILL.md](./skills/cloud-cost-agent/SKILL.md)** — the skill itself (commands, safety rules, audit flow)
- **[docs/](./skills/cloud-cost-agent/docs/)** — per-provider setup and IAM policies
- **[PRODUCT.md](./PRODUCT.md)** — product vision

Contributions and issues welcome.
