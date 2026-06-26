# AWS Setup for Cloud Cost Agent

## Authentication
```bash
aws configure sso          # or: aws configure  (long-lived keys)
aws sts get-caller-identity # confirm the identity/profile you're auditing
```
Use a dedicated **read-only `cost-audit` profile**, not an admin profile. Pass `--profile cost-audit` on every command (or set `AWS_PROFILE`).

## Required Permissions
Attach the bundled least-privilege policy: [`iam-readonly-policy.json`](./iam-readonly-policy.json). It grants read-only access to Cost Explorer (`ce:*` getters), Compute Optimizer, Cost Optimization Hub, the modern billing actions (`billing:Get*`, `cur:GetUsageReport`), and Trusted Advisor cost checks.

Note: the retired `aws-portal:*` actions are intentionally **not** used — AWS replaced them with the fine-grained `billing:`/`ce:`/`cur:` actions in 2023.

## One-time enrollment (required for sections 2 & 4 of the skill)
Several recommendation services need a one-time opt-in before they return data:

```bash
# Compute Optimizer (deep rightsizing + idle)
aws compute-optimizer get-enrollment-status
aws compute-optimizer update-enrollment-status --status Active

# Cost Optimization Hub — global service, reachable only in us-east-1
aws cost-optimization-hub list-enrollment-statuses --region us-east-1
aws cost-optimization-hub update-enrollment-status --status Active --region us-east-1
```
After enrolling, recommendations take **up to ~24h** to populate.

## Service notes / gotchas
- **Cost Explorer is metered** — `aws ce` calls cost ~$0.01 each. Don't loop them; the skill caps calls per audit.
- **Cost Optimization Hub** must be queried with `--region us-east-1`.
- **`get-rds-database-recommendations`** is the current Compute Optimizer command (the old `get-rds-recommendations` is gone).
- **Savings Plans** (`aws ce get-savings-plans-purchase-recommendation`) requires all four params: `--savings-plans-type`, `--term-in-years`, `--payment-option`, `--lookback-period-in-days`.
- **Trusted Advisor cost checks** require a **Business or Enterprise Support** plan; on Basic Support those API calls return access errors (skip them).

## Deep analysis (optional)
For granular line-item data, enable the **Cost and Usage Report (CUR)** to S3 and query it with Athena. Not required for the recommendation-based audit flow.

## Key Commands
See the main [SKILL.md](../SKILL.md) for the full set of `aws ce`, `aws compute-optimizer`, and `aws cost-optimization-hub` examples.
