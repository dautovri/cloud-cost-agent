# cloud-cost-agent

**Cloud Cost Agent** — native cost optimization skills and CLI patterns for the top 3 cloud providers (AWS, Google Cloud, Azure) using only official tools.

Focus: **Save real money on AWS, GCP, and Azure** with agent-friendly skills for Grok, Claude, and similar. No third-party SaaS or dashboards required.

## The Idea

The original cloud-cost project is a web dashboard. This repo takes the **same goal** (cost visibility + actionable savings) and implements it as **lightweight, powerful skills** that run directly in your terminal/agent using each provider's native CLIs and recommendation engines.

- **AWS**: Cost Explorer, Compute Optimizer, Cost Optimization Hub
- **Google Cloud**: Recommender (Active Assist), Billing exports to BigQuery
- **Azure**: Advisor (Cost recommendations), Cost Management / Consumption APIs

## Why Native Agent Skills?

- Fresh data on demand
- Works inside Cursor, Claude Code, Grok, etc.
- Precise control with filters and queries
- Lower overhead than full dashboards
- Stays in your existing auth (aws/gcloud/az login)

## Quick Start

1. Copy the skill:
   ```bash
   mkdir -p ~/.grok/skills/cloud-cost-agent
   cp SKILL.md ~/.grok/skills/cloud-cost-agent/
   # or for Claude: ~/.claude/skills/cloud-cost-agent/
   ```

2. Use it:
   ```
   /cloud-cost-agent audit my AWS spend
   /cloud-cost-agent find quick wins on GCP
   /cloud-cost-agent recommendations for Azure last 90 days
   ```

## Core Native Surfaces by Provider

### AWS
- `aws ce` (Cost Explorer): get-cost-and-usage, rightsizing, Savings Plans recommendations
- `aws compute-optimizer`: rightsizing + idle for EC2, Lambda, EBS, RDS
- `aws cost-optimization-hub`: centralized recommendations with effort/savings filters
- CUR + Athena for deep analysis

### Google Cloud (GCP)
- `gcloud recommender recommendations list`: Machine type rightsizing, idle VMs, committed use discounts, storage, etc.
- Recommender Hub + Active Assist
- Billing export to BigQuery (CUR equivalent)
- `gcloud billing` and `gcloud alpha billing` for some queries

Key recommenders:
- `google.compute.instance.MachineTypeRecommender`
- `google.compute.instance.IdleResourceRecommender`
- Spend-based CUD recommender

### Azure
- `az advisor recommendation list --category Cost`: rightsizing, idle resources, reservations
- `az costmanagement` (export + query for usage/cost data)
- `az consumption usage list` for detailed usage
- Reservations / Savings plans recommendations via Advisor

## Supported Use Cases (All Providers)
- Cost breakdown by service / resource
- Rightsizing / machine type recommendations
- Idle / unused resource detection
- Commitment / reservation / CUD purchase recommendations
- Quick wins prioritization (by estimated savings + effort)
- Exportable reports

## Repository Structure

```
cloud-cost-agent/
├── SKILL.md                 # Main multi-cloud skill (provider-aware)
├── README.md
├── docs/
│   ├── iam-readonly-policy.json   # AWS
│   ├── gcp-setup.md
│   └── azure-setup.md
└── references/              # Additional queries & patterns
```

## Design Principles
- Native only — use the provider's own recommendation engines.
- Agent-optimized — clean JSON output, safe `--query` filters.
- Safe by default — read-only first, explicit confirmation for changes.
- Multi-cloud ready — one skill to rule them all or focus per provider.
- Prioritize impact — sort by $ savings, then implementation effort.

## Next Steps / Roadmap
- Add more detailed playbooks per provider (storage, networking, data transfer)
- CUR/BigQuery/Athena style query libraries for each
- Unified savings calculator across clouds
- Integration hooks back to the main cloud-cost dashboard (if used)

## Resources
- AWS: Well-Architected Cost Optimization Pillar + docs linked in SKILL.md
- GCP: https://cloud.google.com/recommender/docs
- Azure: https://learn.microsoft.com/azure/cost-management-billing + Advisor docs

This is a private/internal repo for fast iteration on cloud cost agent skills.

---

Run `/cloud-cost-agent` to start saving money across your clouds.