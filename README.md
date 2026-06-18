# cloud-cost-agent

**Cloud Cost Agent** — the open-source, native-first FinOps agent skills for AWS, GCP, and Azure.

**Tagline**: Actionable cloud cost savings inside your AI coding agent (Claude Code, Cursor, Gemini CLI, Grok, etc.). Purely native tools. No new SaaS dashboard required.

Focus: **Save real money** using each provider's official CLIs and recommendation engines (Cost Explorer/Compute Optimizer/Hub, Recommender, Advisor, etc.).

## Why This Product?

Cloud bills are exploding, but most tools are heavy dashboards that duplicate native capabilities. AI agents are transforming how we work — yet they lack accurate, provider-specific FinOps knowledge.

Cloud Cost Agent fills the gap with **portable skills + lightweight CLI + MCP tools** that:
- Leverage native recommenders directly for fresh, authoritative data.
- Deliver structured playbooks and exact CLI commands inside any compatible agent.
- Enable shift-left cost decisions and (guarded) automation.

**Differentiation**:
- Native-only core (no mandatory data ingestion).
- Agent-native by design (SKILL.md format — works across tools).
- Multi-cloud from day one.
- Lightweight and open-core.

See [PRODUCT.md](./PRODUCT.md) for full vision, monetization, and roadmap.

## Market Context (2026)
AI FinOps agents are a major trend (Vantage FinOps Agent with GitHub remediation, AWS Bedrock samples, emerging skills repos). Teams want **action**, not more dashboards. Native + skills is the lightweight, developer-friendly path.

## Quick Install (One Command)

```bash
# For most agents (Claude Code, Cursor, Gemini CLI, etc.)
curl -sL https://raw.githubusercontent.com/dautovri/cloud-cost-agent/main/install.sh | bash

# Or manually copy the skill
mkdir -p ~/.grok/skills/cloud-cost-agent
cp SKILL.md ~/.grok/skills/cloud-cost-agent/
```

Supports the emerging Agent Skills / SKILL.md standard (portable to Claude, Gemini CLI, Cursor, and more).

## Core Usage

```
/cloud-cost-agent audit my AWS spend last 30 days
/cloud-cost-agent find quick wins on GCP and Azure
/cloud-cost-agent rightsizing recommendations --provider all
```

The skill branches intelligently per provider and outputs:
- Native CLI commands with safe filters.
- Prioritized savings (by $ impact + effort).
- Concrete next steps.

## Core Native Surfaces

### AWS
- `aws ce`, `aws compute-optimizer`, `aws cost-optimization-hub`
- CUR + Athena for depth

### Google Cloud
- `gcloud recommender` (MachineType, IdleResource, CUDs, etc.)
- Billing export to BigQuery

### Azure
- `az advisor recommendation list --category Cost`
- `az costmanagement` / consumption for data
- Reservations & Advisor

## Features (Current + Planned)

**Free / Open Core**
- Multi-provider SKILL.md + 20+ playbooks (rightsizing, idle, commitments, waste taxonomy, etc.)
- CLI helper for direct audits
- MCP server for agent tool calling
- Install for popular coding agents
- GitHub examples for PR suggestions

**Growth / Paid Layers** (roadmap)
- Hosted agent + MCP
- Automated remediation with guardrails (GitHub integration)
- Advanced reporting & savings tracking
- Enterprise features (SSO, policies, custom playbooks)
- Outcome pricing (share of realized savings)

## Positioning vs Competitors
- Vs Vantage/CloudZero/Amnic: No heavy platform lock-in for core use. Skills work in your existing agent.
- Vs pure dashboards: Actionable + agent-integrated from the start.
- Vs AWS-only Bedrock agents: True multi-cloud (AWS+GCP+Azure) with portable skills.

## Get Involved / Productize
- Star the repo and try the skill.
- Contribute playbooks or provider deep-dives.
- Use as foundation for internal tools or a commercial product (open-core model works well — see similar FinOps skills repos).
- Feedback welcome on GitHub issues.

## Quick Start (Manual)

1. Copy the skill into your agent skills directory.
2. Authenticate to the clouds you use (`aws`, `gcloud`, `az login`).
3. Ask your agent: "Use cloud-cost-agent to find savings opportunities."

See SKILL.md for detailed instructions and safety rules.

## Resources
- [PRODUCT.md](./PRODUCT.md) — Full product vision and roadmap
- Native docs: AWS Well-Architected Cost Pillar, GCP Recommender, Azure Advisor
- Related: FinOps Foundation, FOCUS spec

Built to turn native cloud capabilities into agent-powered savings at scale.

---

*This is the evolution of cost visibility into the agent era — native, portable, actionable.*

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