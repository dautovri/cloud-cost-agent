---
name: cloud-cost-agent
description: Use when analyzing cloud spend, running a cost audit, or finding savings across AWS, Google Cloud, and Azure — rightsizing, idle resources, and commitment/reservation recommendations, per-provider or cross-cloud. Uses only native CLIs and recommendation services (Cost Explorer/Compute Optimizer/Cost Optimization Hub, GCP Recommender, Azure Advisor + Cost Management) to produce prioritized savings reports.
allowed-tools: Bash
---

# Cloud Cost Agent (AWS + GCP + Azure)

Unified agent skill for **native cloud cost optimization** across the top 3 providers.

**Requirements**: AWS CLI, `gcloud`, and/or Azure CLI configured with read access to billing/recommender/advisor services. Some sources need opt-in (e.g. AWS Compute Optimizer, GCP Recommender).

**Core rule**: Always use the provider's official CLI and recommendation engines. No third-party tools.

## Safety & Best Practices (All Providers)
- Start read-only.
- Always use provider auth (`--profile`, `gcloud --project`, `az account set`).
- Use `--query` / `--format json` for clean output.
- Prioritize: highest estimated savings → lowest effort.
- Confirm before any change (delete, resize, purchase commitment).
- Prefer quick wins (idle delete, rightsizing to smaller, enable committed use where clear).

## How to Use
Tell the agent the provider(s) and goal:

Examples:
- `/cloud-cost-agent audit AWS last 30 days`
- `/cloud-cost-agent find quick wins on GCP and Azure`
- `/cloud-cost-agent rightsizing recommendations for all clouds`

The skill will branch to the correct native commands.

## 1. Pre-flight & Authentication

**AWS**
```bash
aws sts get-caller-identity
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY --metrics "UnblendedCost"
```

**GCP**
```bash
gcloud auth list
gcloud config set project YOUR_PROJECT
gcloud billing accounts list
```

**Azure**
```bash
az account show
az account set --subscription "SUB_ID"
```

## 2. Centralized / High-Impact Recommendations

### AWS (Cost Optimization Hub — best aggregator)
```bash
aws cost-optimization-hub list-recommendations \
  --filter '{"implementationEfforts":["VeryLow","Low"]}' \
  --query 'items[?estimatedMonthlySavings > `10`] | sort_by(@, &estimatedMonthlySavings) | reverse(@)' \
  --output json
```

### GCP (Recommender — main source)
List top cost recommenders (machine type, idle, CUDs):

```bash
# Rightsizing VMs
gcloud recommender recommendations list \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --project=YOUR_PROJECT \
  --location=us-central1-a \
  --format=json

# Idle resources
gcloud recommender recommendations list \
  --recommender=google.compute.instance.IdleResourceRecommender \
  --project=YOUR_PROJECT \
  --format="table(description, primaryImpact.costProjection.cost.units, stateInfo.state)"

# Committed Use Discounts
gcloud recommender recommendations list \
  --recommender=google.cloudbilling.commitment.SpendBasedCommitmentRecommender \
  --billing-project=YOUR_BILLING_PROJECT
```

### Azure (Advisor Cost category)
```bash
az advisor recommendation list \
  --category Cost \
  --query "[].{Resource: shortDescription.problem, Impact: impact, AnnualSavings: extendedProperties.annualSavingsAmount, Currency: extendedProperties.savingsCurrency}" \
  -o table

# More detailed
az advisor recommendation list --category Cost \
  --query "[?impact=='High'].{Id:id, Resource:resourceMetadata.resourceId, Savings:extendedProperties.annualSavingsAmount}" -o json
```

## 3. Cost & Usage Breakdown

**AWS**
```bash
aws ce get-cost-and-usage \
  --time-period Start=$(date -v-30d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

**GCP**
Use BigQuery export (recommended) or:
```bash
gcloud billing accounts get-iam-policy BILLING_ACCOUNT
# For detailed: query your BigQuery billing export table
```

**Azure**
```bash
# Usage details
az consumption usage list --start-date $(date -v-30d +%Y-%m-%d) --end-date $(date +%Y-%m-%d) \
  --query "[].{Resource:instanceName, Service:consumedService, Cost:pretaxCost}" -o table

# Or via costmanagement export + query (for aggregated)
az costmanagement export list --scope "/subscriptions/..."
```

## 4. Rightsizing & Compute Recommendations

**AWS** — see Compute Optimizer section in original AWS skill (get-ec2-instance-recommendations, etc.)

**GCP**
```bash
gcloud recommender recommendations list \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --format=json | jq '.[] | select(.primaryImpact.costProjection.cost.units < 0)'
```

**Azure**
Advisor Cost recommendations already include VM rightsizing and underutilized resources.

## 5. Commitments & Discounts

**AWS**: Savings Plans / RIs via `aws ce get-savings-plans-purchase-recommendation`

**GCP**: Committed Use Discounts via Recommender (SpendBasedCommitmentRecommender + CUD recommenders)

**Azure**: 
```bash
# Reservation recommendations surface in Advisor Cost
az advisor recommendation list --category Cost \
  --query "[?contains(shortDescription.problem, 'reserved') || contains(shortDescription.problem, 'reservation')]"
```

## 6. Prioritization Template (for any provider)

When summarizing:
1. Total estimated monthly / annual savings.
2. Quick wins bucket (VeryLow/Low effort or equivalent).
3. Top 5-8 items with: Resource, Current state, Recommended action, $ savings, Effort/risk.
4. Concrete next command for the top item.

Example output structure:
```
Provider: GCP
Total potential monthly savings: $2,340

Quick wins:
- Delete idle VM ... : $180/mo (VeryLow)
- Rightsize n1-standard-8 → n2-standard-4 : $420/mo

Next command:
gcloud recommender recommendations list --recommender=google.compute.instance.IdleResourceRecommender ...
```

## Provider-Specific Quick Commands Reference

### AWS (most mature centralized tools)
- Hub for broad view
- Compute Optimizer for deep rightsizing
- Full details in previous AWS-only version of this skill

### GCP
Key recommenders to always check:
- MachineTypeRecommender (rightsizing)
- IdleResourceRecommender (VMs, images, disks, IPs)
- SpendBasedCommitmentRecommender
- Storage and BigQuery specific ones

Use `--location` for zonal recommenders and project scope.

### Azure
- Advisor is the primary source for Cost recommendations.
- Pair with `az consumption` or `az costmanagement` for raw usage.
- Export jobs (`az costmanagement export create`) for CUR-like data.

## Full Audit Flow (Recommended)

1. Authenticate to the desired cloud(s).
2. Pull high-level cost summary for last 30/90 days.
3. Pull recommendations (Hub / Recommender / Advisor).
4. Filter for savings > threshold and low effort.
5. Cross-check with raw usage if needed.
6. Produce prioritized list + 3 concrete next actions.
7. (Optional) Repeat for other providers.

## Extending
Add new sections for:
- Storage optimization (S3/GCS/Blob lifecycle)
- Networking / data transfer
- Kubernetes / container cost tuning
- Anomaly detection equivalents

Keep all commands safe, copy-pasteable, and focused on native capabilities.

## References

**AWS**
- Cost Explorer / Compute Optimizer / Cost Optimization Hub docs (see previous)

**GCP**
- Recommender docs: https://cloud.google.com/recommender/docs/recommenders
- Active Assist / Cost optimization

**Azure**
- Azure Advisor cost recommendations: https://learn.microsoft.com/azure/advisor/advisor-reference-cost-recommendations
- Cost Management CLI: az costmanagement
- Consumption usage

This skill is designed to be the go-to agent for real cloud cost savings across AWS, GCP, and Azure using only what each provider gives you.

---

Run it with a specific provider or across all three. Stay native. Stay effective.