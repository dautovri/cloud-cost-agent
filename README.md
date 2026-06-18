# aws-cost-optimizer

AWS-native cost optimization skills, CLI patterns, and references for Grok and Claude agents.

Focus: **Save money on AWS using only official AWS services** — no third-party dashboards or SaaS required.

## Why This Exists

Most cloud cost tools are heavy web dashboards that duplicate what AWS already provides well. This project delivers **agent-first, CLI-powered skills** that let you (or an AI agent) directly:

- Pull fresh, authoritative recommendations
- Quantify real savings opportunities
- Prioritize by impact + effort
- Generate exact commands and reports
- Stay inside the AWS security and data boundary

Built for use inside Grok Build, Claude Code, Cursor, or any terminal-based agent workflow.

## Core AWS-Native Surfaces

- **Cost Explorer** (`aws ce`)
  - `get-cost-and-usage`, `get-rightsizing-recommendation`
  - Savings Plans purchase recommendations, utilization, forecasts, anomalies

- **Compute Optimizer** (`aws compute-optimizer`)
  - Rightsizing for EC2, Auto Scaling Groups, Lambda, EBS, RDS
  - Idle resource detection + projected metrics

- **Cost Optimization Hub** (`aws cost-optimization-hub`)
  - `list-recommendations` — centralized, filterable view across all sources
  - Best single source for agents (filter by effort, action type, savings)

- **Trusted Advisor** (cost_optimizing checks via `aws support`)
- **Cost and Usage Reports (CUR) + Athena** (deep custom analysis)
- Supporting: Budgets, Savings Plans, S3 lifecycle patterns, tagging

## Quick Start (as a Skill)

1. Copy `SKILL.md` into your skills directory:
   - `~/.grok/skills/aws-cost-optimizer/SKILL.md`
   - or `~/.claude/skills/aws-cost-optimizer/SKILL.md`

2. (Optional) Add the skill via `/create-skill` flow and paste the content.

3. Invoke:
   ```
   /aws-cost-optimizer analyze my spend last 30 days
   /aws-cost-optimizer find quick wins
   ```

See [SKILL.md](./SKILL.md) for the full prompt package.

## Recommended IAM Permissions (read-only)

Use least-privilege. Key managed policies + actions:

- `CostOptimizationHubReadOnlyAccess`
- `ComputeOptimizerReadOnlyAccess`
- Cost Explorer / billing read access (see AWS docs for `ce:*` and Billing Console activation)

Example minimal policy available in `docs/iam-readonly-policy.json` (to be added).

## Repository Structure

```
aws-cost-optimizer/
├── SKILL.md                 # Primary Grok/Claude skill definition
├── README.md
├── .gitignore
├── docs/                    # References, IAM snippets, runbooks
│   └── ...
└── references/              # Curated CUR queries, command examples
```

## Design Principles

- **AWS only** — every recommendation and data source comes from AWS APIs/CLI.
- **Agent-friendly** — clean JSON output, strong filters, actionable next steps.
- **Safe by default** — read-only commands first. Any mutating action requires explicit confirmation.
- **Prioritize impact** — sort by estimated monthly savings, then by implementation effort (VeryLow/Low first).
- **Reproducible** — document exact commands so humans or agents can re-run.

## Useful Commands (examples)

```bash
# Top rightsizing opportunities (Compute Optimizer)
aws compute-optimizer get-ec2-instance-recommendations \
  --filters name=Finding,values=Overprovisioned \
  --query 'instanceRecommendations[?estimatedMonthlySavings>`0`]'

# Centralized recommendations from Cost Optimization Hub (very powerful)
aws cost-optimization-hub list-recommendations \
  --filter '{"implementationEfforts":["VeryLow","Low"],"actionTypes":["Rightsize","Stop","Delete"]}' \
  --query 'items | sort_by(@, &estimatedMonthlySavings) | reverse(@)' \
  --output json

# Savings Plans recommendations
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years THREE_YEARS \
  --payment-option NO_UPFRONT
```

See `SKILL.md` for many more templated, safe, query-heavy examples.

## Resources

- [AWS Well-Architected Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [Cost Explorer CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ce/)
- [Compute Optimizer CLI](https://docs.aws.amazon.com/cli/latest/reference/compute-optimizer/)
- [Cost Optimization Hub](https://docs.aws.amazon.com/cost-management/latest/userguide/cost-optimization-hub.html)
- [CUR Query Library (Well-Architected Labs)](https://www.wellarchitectedlabs.com/cost-optimization/cur_queries/)

## Private Repo

This is an internal/private repository for fast iteration on skills and patterns.

## License

Internal use. MIT-style if extracted later.

## Contributing

For the owner: edit `SKILL.md`, improve command templates, add new high-signal playbooks, keep everything strictly AWS-native.

---

Generated as the dedicated home for AWS-native cost saving skills and tooling.