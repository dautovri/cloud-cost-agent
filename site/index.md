# cloud-cost-agent — the FinOps audit without the FinOps platform

An open-source AI agent skill that finds cloud savings using each provider's own recommendation engines — right inside Claude Code, Cursor, or Gemini. No dashboard. No data ingestion. Free.

## Install

```
npx skills add dautovri/cloud-cost-agent
```

Works with Claude Code, Cursor, Codex, Gemini CLI & 70+ agents.

**Reads straight from:** AWS Cost Explorer · Compute Optimizer · Cost Optimization Hub · GCP Recommender · Azure Advisor

## The problem

FinOps dashboards tell finance you're over budget. They don't help engineering fix it.

Most cost platforms are a paid wrapper around recommendations your cloud already computes for free — plus weeks of onboarding, a cross-account IAM read role, and a dashboard your engineers never open. The savings are sitting in native APIs right now. You just need something to read them and rank them where you already work.

## Why a skill, not a SaaS

### No vendor ingestion
Runs on the CLI credentials you already have — no cross-account read role to grant, no 24-hour sync, no billing export to a third-party FinOps database.

### Native APIs = ground truth
Queries Cost Explorer, Compute Optimizer, GCP Recommender and Azure Advisor directly — no third-party cost miscalculation or custom-discount drift.

### Lives in your agent
One prompt in Claude Code, Cursor or Gemini. No context-switch to a portal — the insights come to the tool you already have open.

### Prioritized, not raw
Output ranked by estimated savings and effort, with the exact next command — not a wall of line-items to triage yourself.

### Cross-cloud in one pass
AWS, GCP and Azure in a single audit flow — no three separate tools, no consultant, no normalization project.

### Read-only by default
Audits never mutate infrastructure. Any change is quoted back to you and requires explicit approval before it runs.

## How it works

### 1. Install the skill
`npx skills add dautovri/cloud-cost-agent` — or add it as a Claude Code plugin. No account, no signup.

### 2. Use your own auth
You're already logged in: `aws`, `gcloud`, `az`. The skill uses those credentials — nothing new to provision.

### 3. Ask for an audit
"Find quick wins on AWS and GCP." Get a ranked savings report with the next command for each item.

### Example output

```
you ▸ audit AWS & GCP, last 30 days, quick wins only

# pulling Cost Optimization Hub (us-east-1) + GCP Recommender…

Provider: AWS   potential savings ~$1,910/mo
  ▸ 3× idle EBS volumes (gp2, unattached)      $240/mo  VeryLow
  ▸ Rightsize m5.2xlarge → m5.large (i-0a3f)   $520/mo  Low
  ▸ Compute Savings Plan, 1yr no-upfront        $1,150/mo Low

Provider: GCP   potential savings ~$430/mo
  ▸ Idle VM in us-central1-a (stop/delete)     $180/mo  VeryLow
  ▸ n1-standard-8 → n2-standard-4              $250/mo  Low

# next: aws compute-optimizer get-ebs-volume-recommendations
```

## Honest comparison: vs FinOps SaaS

| Capability | cloud-cost-agent | FinOps SaaS |
|---|---|---|
| Native rightsizing & idle recommendations | Yes | Yes |
| Cross-cloud audit in one flow | Yes | Yes |
| Setup time | Minutes | Days–weeks |
| Data ingestion / IAM read role | None | Required |
| Cost | Free / OSS | $$ / % of spend |
| Continuous monitoring & anomaly alerts | No | Yes |
| Historical trends & baselines | No | Yes |
| Allocation / showback / chargeback | No | Yes |
| Executive / finance dashboards | No | Yes |

## Who it's for

- Engineers & platform/SRE leads doing cost hygiene
- Startups avoiding another SaaS bill and onboarding
- Anyone who wants "what should we fix right now?"
- Teams already living in Claude Code, Cursor or Gemini

## Who this is not for

- Finance-led FinOps teams needing unit economics & chargeback
- Continuous spend monitoring and anomaly alerting
- Historical trend graphs for stakeholders
- Centralized governance across 50+ accounts

If that's you, keep Vantage, CloudZero, or similar — they do a different job, well.

## Security & threat model

**What stays out of it:**
- No cloud-cost-agent backend, no third-party FinOps database, no IAM role handed to a vendor.
- Read-only first — any change is quoted back to you and needs explicit approval.
- Ships a least-privilege read-only IAM policy. Use a dedicated cost-audit profile, not admin SSO.
- Episodic and scoped — not a SaaS holding persistent access to every account.

**The honest boundary:**
The output of your `aws`/`gcloud`/`az` commands flows through your agent session into your LLM provider's context — the same trust you already extend to Claude Code or Cursor with your source code. It removes the FinOps vendor from the loop, not the model provider.

If your org forbids sending infra metadata to an LLM, run a local model — or don't use this. We won't pretend otherwise.

## FAQ

**Does this replace Vantage or CloudZero?**
No — and it doesn't try to. Those platforms provide continuous monitoring, historical data, allocation and finance reporting. This skill does episodic, native, cross-cloud savings audits inside your agent. Different job.

**Is it safe to run against production accounts?**
Yes. It's read-only first — audits only call cost/recommendation APIs. Any change is quoted back to you and requires explicit approval before it runs.

**Where does my billing data go?**
There's no cloud-cost-agent backend and no third-party FinOps database. But the output of your cloud CLI commands flows through your agent session into your LLM provider's context — the same trust you already extend when using Claude Code or Cursor with your source code.

**What does it actually query?**
AWS Cost Explorer, Compute Optimizer and Cost Optimization Hub; GCP Recommender (machine-type, idle, committed-use); Azure Advisor and Cost Management.

**Does it handle multiple accounts or org-wide spend?**
It runs against whatever your CLI profile is authenticated to. There's no centralized multi-account RBAC layer — that's squarely SaaS territory.

**Is it really free?**
Yes — open source under MIT. The only cost is the providers' own metered APIs (e.g. AWS Cost Explorer bills ~$0.01 per request).

## Links

- [GitHub](https://github.com/dautovri/cloud-cost-agent)
- [SKILL.md](https://github.com/dautovri/cloud-cost-agent/blob/main/skills/cloud-cost-agent/SKILL.md)
- [skills.sh](https://skills.sh)

---
Open source (MIT). Native-first FinOps for AWS, GCP & Azure. Not affiliated with AWS, Google or Microsoft.
