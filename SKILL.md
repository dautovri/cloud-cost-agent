---
name: aws-cost-optimizer
description: AWS-native cost optimization and savings using only official AWS services (Cost Explorer, Compute Optimizer, Cost Optimization Hub, CUR). Use when the user wants to analyze AWS spend, find savings opportunities, run a cost audit, get rightsizing recommendations, Savings Plans advice, or generate actionable optimization reports with Grok or Claude.
when-to-use: Analyze AWS bill, find waste, rightsizing, idle resources, savings plans, cost optimization audit, quick wins on AWS spend.
allowed-tools: Bash
compatibility: Requires AWS CLI v2 configured with read access to ce, compute-optimizer, cost-optimization-hub, and (optionally) support. Activate Cost Explorer and opt-in to Compute Optimizer + Cost Optimization Hub.
---

# AWS Cost Optimizer (Native)

Perform a complete, high-signal cost optimization audit and savings analysis **using only official AWS tools and APIs**.

Never rely on third-party dashboards. Pull live data, quantify savings, prioritize by impact + effort, and produce clear next actions.

## Safety Rules (Strict)

- All commands start **read-only**.
- Always specify `--profile` and `--region` when relevant.
- Use `--query` and `--output json` for clean, parseable results.
- Never run delete, purchase, or resize commands without explicit user confirmation ("yes, apply this").
- Prefer filters that surface quick wins first (VeryLow/Low effort, high savings).

## 1. Pre-flight (Foundations)

```bash
# Who am I and what accounts?
aws sts get-caller-identity
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --query 'ResultsByTime[0].Total'

# Check opt-in status (important)
aws compute-optimizer get-enrollment-status
aws cost-optimization-hub list-enrollment-statuses 2>/dev/null || echo "Cost Optimization Hub may need opt-in"
```

**If not opted in:**
- Console: Billing → Cost Optimization Hub → Opt in
- Compute Optimizer: Enable via console or `aws compute-optimizer update-enrollment-status --status Active`

## 2. Centralized Recommendations (Best Starting Point)

Use **Cost Optimization Hub** — it aggregates the best signals.

```bash
# Quick wins only (VeryLow + Low effort)
aws cost-optimization-hub list-recommendations \
  --filter '{
    "implementationEfforts": ["VeryLow", "Low"],
    "actionTypes": ["Rightsize", "Stop", "Delete", "MigrateToGraviton"]
  }' \
  --query 'items[?estimatedMonthlySavings > `5`] | sort_by(@, &estimatedMonthlySavings) | reverse(@)' \
  --output json

# All high-impact recommendations (sorted by savings)
aws cost-optimization-hub list-recommendations \
  --order-by dimension=EstimatedMonthlySavings,order=Desc \
  --query 'items[?estimatedMonthlySavings > `20`]' \
  --output json
```

Key fields to highlight:
- `estimatedMonthlySavings`
- `actionType`
- `implementationEffort`
- `resourceType` / `resourceId`
- `restartNeeded`, `rollbackPossible`

## 3. Rightsizing & Compute Recommendations

```bash
# Over-provisioned EC2 instances
aws compute-optimizer get-ec2-instance-recommendations \
  --filters name=Finding,values=Overprovisioned \
  --query 'instanceRecommendations[].{Instance: instanceArn, Current: currentInstanceType, Recommendation: recommendationOptions[0].instanceType, Savings: estimatedMonthlySavings, PerformanceRisk: recommendationOptions[0].performanceRisk}' \
  --output table

# Lambda rightsizing
aws compute-optimizer get-lambda-function-recommendations \
  --filters name=Finding,values=Underprovisioned,Overprovisioned

# EBS volumes (often big quick wins)
aws compute-optimizer get-ebs-volume-recommendations
```

Also pull projected metrics when evaluating a specific recommendation:
```bash
aws compute-optimizer get-ec2-recommendation-projected-metrics \
  --instance-arn <arn> \
  --recommended-instance-type <type>
```

## 4. Savings Plans & Commitments

```bash
# Compute Savings Plans recommendation (most flexible)
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years ONE_YEAR \
  --payment-option NO_UPFRONT \
  --lookback-period-in-days THIRTY_DAYS \
  --query 'savingsPlansPurchaseRecommendation'

# Check current coverage/utilization
aws ce get-savings-plans-coverage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY
```

## 5. Cost Explorer Deep Dive

```bash
# Last 30 days by service (top spenders)
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'ResultsByTime[].Groups[?Metrics.UnblendedCost.Amount > `1`]'

# By instance type (great for rightsizing context)
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-90d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=INSTANCE_TYPE
```

## 6. Idle & Waste Resources (via CUR + Compute Optimizer)

When CUR is enabled, combine with Athena queries from the Well-Architected Labs library or use:

```bash
# Idle recommendations (newer Compute Optimizer capability)
aws compute-optimizer get-idle-recommendations
```

Common high-ROI waste categories to check manually via CLI or CUR:
- Unattached EBS volumes
- Old snapshots
- Idle NAT Gateways / Load Balancers
- Over-provisioned storage

## 7. Trusted Advisor Cost Checks (Business+)

```bash
# List cost optimization checks
aws support describe-trusted-advisor-checks \
  --language en \
  --query "checks[?category=='cost_optimizing'].{Name:name, Id:id}" \
  --output table

# Example: get results for a specific check ID
aws support describe-trusted-advisor-check-result \
  --check-id <check-id> \
  --query 'result'
```

## 8. Prioritization & Reporting

When presenting results to the user or in an agent response, always:

1. Calculate **total estimated monthly savings**.
2. Break down into buckets: Quick wins (VeryLow/Low effort), Medium, High.
3. List top 5-10 with:
   - Resource / service
   - Current vs recommended (if applicable)
   - $ savings
   - Effort + risk notes
4. End with 2-3 concrete next CLI commands the user (or agent) can run.

Example summary template:
```
Total potential monthly savings: $X,XXX

Quick wins ($Y):
- Rightsize i-abc123 t3.large → t3.medium : $48/mo (VeryLow effort)
- Delete unattached EBS vol-xyz : $22/mo (VeryLow)

Next actions:
aws cost-optimization-hub get-recommendation --recommendation-id ...
```

## 9. Full Monthly Audit Flow (recommended)

1. Run the Cost Optimization Hub quick-wins query (step 2).
2. Run Compute Optimizer overprovisioned + idle (step 3).
3. Check Savings Plans opportunity (step 4).
4. Get top 3 services by spend from Cost Explorer (step 5).
5. Produce one combined report with prioritized list + total savings.
6. Ask user which category to drill deeper or action.

## References (keep these handy)

- Well-Architected Cost Optimization Pillar: https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html
- Cost Explorer CLI: https://docs.aws.amazon.com/cli/latest/reference/ce/
- Compute Optimizer CLI: https://docs.aws.amazon.com/cli/latest/reference/compute-optimizer/
- Cost Optimization Hub: https://docs.aws.amazon.com/cost-management/latest/userguide/coh-getting-started.html
- CUR Query Library: https://www.wellarchitectedlabs.com/cost-optimization/cur_queries/

## Extending This Skill

Add new playbooks as additional sections:
- Storage optimization (S3 Intelligent-Tiering, gp2→gp3)
- Data transfer analysis
- Tagging & cost allocation gaps
- Anomaly response

Always keep commands copy-paste safe and output-friendly for agents.

---

This skill is designed to be the single source of truth for AWS-native cost saving actions inside an agent. Keep it focused, safe, and brutally effective.