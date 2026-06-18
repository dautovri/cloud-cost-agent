# Cloud Cost Agent — Product Vision

**Tagline**: Native-first FinOps agent skills for AWS, GCP, and Azure. Actionable cost savings inside your AI coding agent — no new dashboard required.

## Problem
Traditional cloud cost tools are heavy SaaS dashboards that duplicate what each provider already offers natively (Cost Explorer, Recommender, Advisor). Engineers and FinOps teams waste time switching contexts, while AI coding agents (Claude Code, Cursor, Gemini CLI, Grok) lack deep, provider-accurate FinOps knowledge.

Result: Billions in wasted cloud spend, slow remediation, and agents giving generic or incorrect advice.

## Solution
**Cloud Cost Agent** is an open, portable set of **agent skills** + lightweight CLI + MCP tools that:
- Directly leverage each cloud's native recommendation engines and CLIs.
- Deliver structured, actionable playbooks inside any compatible AI agent.
- Enable shift-left cost decisions and automated (guarded) remediation.

**Differentiation**:
- Purely native (no data ingestion into third-party SaaS for core use).
- Agent-native by design (SKILL.md format works in Claude, Gemini CLI, Cursor, etc.).
- Multi-cloud from day one (top 3 providers).
- Lightweight & open-core.

## Target Users
- Platform / DevOps / SRE engineers using AI coding agents.
- FinOps practitioners wanting agent augmentation.
- Small-to-mid teams avoiding expensive CCM platforms.
- Enterprises wanting native + agentic workflows with guardrails.

## Core Product (Free / Open Core)
- `SKILL.md` + reference playbooks (rightsizing, idle cleanup, commitments, waste detection, etc.).
- One-command install for multiple agents.
- CLI helper for direct native audits (`cloud-cost-agent audit --provider all`).
- MCP server for tool-calling agents.
- GitHub examples for PR-based remediation suggestions.

## Paid / Growth Layers
- Hosted agent or MCP backend.
- Advanced automation (scheduled audits, policy enforcement, GitHub integration with approval).
- Premium playbooks and cross-cloud reporting.
- Outcome-based: % of realized savings on autonomous actions.
- Enterprise: SSO, audit logs, custom policies, support.

## Competitive Landscape (2026)
- Dashboards (Vantage, CloudZero, Amnic): Strong visibility, adding agents.
- Agent tools (Vantage FinOps Agent with GitHub PRs, AWS Bedrock samples): Action-oriented but often tied to one ecosystem or heavy platform.
- Our edge: Native purity + portable skills format + multi-cloud focus + zero new login for core workflows.

See competitors:
- Vantage FinOps Agent (chat + remediation).
- AWS sample-finops-agent (Bedrock + MCP).
- Emerging skills repos (OptimNow, Cletrics).

## Go-to-Market
1. Open-source on GitHub as the canonical skills package.
2. Publish to agent skill marketplaces / one-liners (npx skills add, install.sh).
3. Content: "How we cut $X with native agents" case studies.
4. Integrations: Gemini CLI, Claude Code, Cursor.
5. Community: Playbook contributions, FinOps Foundation alignment (FOCUS).

## Roadmap (High-Level)
- Q2 2026: Core multi-provider skills + CLI + MCP v1.
- Q3: GitHub App for PR suggestions, Gemini CLI first-class.
- Q4: Hosted agent option, savings tracking, basic automation.
- 2027: Full autonomous mode with guardrails, % savings pricing, enterprise features.

## Success Metrics
- Installs / stars.
- % of users who run successful audits and implement at least one recommendation.
- Community contributions (new playbooks).
- (Paid) Retention and realized savings reported.

This is the lightweight, developer-first alternative to bloated cost platforms — powered by agents, grounded in native tools.

Built as the evolution of the original cloud-cost dashboard into the agent era.
