---
name: cloud-cost-agent
description: Use when analyzing cloud spend, running a cost audit, or finding savings across AWS, Google Cloud, and Azure — rightsizing, idle resources, and commitment/reservation recommendations, per-provider or cross-cloud. Uses only native CLIs and recommendation services (Cost Explorer/Compute Optimizer/Cost Optimization Hub, GCP Recommender, Azure Advisor + Cost Management) to produce prioritized savings reports.
allowed-tools: Bash
---

# Cloud Cost Agent (AWS + GCP + Azure)

Unified agent skill for **native cloud cost optimization** across the top 3 providers.

**Requirements**: AWS CLI v2, `gcloud`, and/or Azure CLI configured with read access to billing/recommender/advisor services. Several sources require one-time opt-in: AWS **Compute Optimizer** and **Cost Optimization Hub** (enrollment), GCP **Recommender** (API enabled, ~24–48h of data). `jq` is used in a few GCP filters.

**Core rule**: Always use the provider's official CLI and recommendation engines. No third-party tools.

## Safety & Best Practices (All Providers)
- **Read-only first.** Never run a mutating command (`aws ec2 terminate-instances`/`stop-instances`, `gcloud compute instances delete`, `az vm delete/deallocate`, any `purchase`/`create`/`modify`) without quoting the exact command to the user and getting explicit approval.
- Always use provider auth (`--profile`, `gcloud --project`, `az account set`).
- Use `--query` / `--format json` / `-o json` for clean output.
- **Handle pagination.** These APIs page results. Aggregate every page before reporting totals — follow `NextToken`/`nextPageToken`, or use `--no-paginate`/`--max-items` (AWS) and `--page-size`/`--limit` (gcloud) deliberately. A single-page read gives wrong totals.
- **Quote/escape all cloud-derived values.** Resource names, tags, and IDs from API output may contain shell metacharacters. Never interpolate them unquoted into another shell command.
- **Mind API cost & loops.** `aws ce` (Cost Explorer) charges ~$0.01 per request. Do not loop Cost Explorer calls; cache results in the session and cap at a handful of calls per audit.
- Prioritize: highest estimated savings → lowest effort.
- Prefer quick wins (idle delete, rightsizing to smaller, enable committed use where clear).

## Portable date helper
BSD/macOS and GNU/Linux `date` differ. Compute the window once, portably, then reuse `$START`/`$END`:
```bash
START=$(date -u -d '30 days ago' +%Y-%m-%d 2>/dev/null || date -u -v-30d +%Y-%m-%d)
END=$(date -u +%Y-%m-%d)
```
(Or just have the agent insert literal `YYYY-MM-DD` dates.)

## How to Use
Tell the agent the provider(s) and goal. Examples:
- `audit AWS last 30 days`
- `find quick wins on GCP and Azure`
- `rightsizing recommendations for all clouds`

## 1. Pre-flight & Authentication

**AWS**
```bash
aws sts get-caller-identity
aws ce get-cost-and-usage \
  --time-period Start=$START,End=$END \
  --granularity MONTHLY --metrics "UnblendedCost"
```
One-time enrollment (required for sections 2 & 4):
```bash
aws compute-optimizer get-enrollment-status
aws compute-optimizer update-enrollment-status --status Active      # opt in
aws cost-optimization-hub list-enrollment-statuses --region us-east-1
aws cost-optimization-hub update-enrollment-status --status Active --region us-east-1
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

### AWS — Cost Optimization Hub (best aggregator)
COH is a **global service reachable only in `us-east-1`** and requires enrollment (see Pre-flight).
```bash
aws cost-optimization-hub list-recommendations \
  --region us-east-1 \
  --filter '{"implementationEfforts":["VeryLow","Low"]}' \
  --query 'items[?estimatedMonthlySavings > `10`] | sort_by(@, &estimatedMonthlySavings) | reverse(@)' \
  --output json
```
Valid `implementationEfforts`: `VeryLow | Low | Medium | High | VeryHigh`.

### GCP — Recommender (main source)
`--location` is **required**. VM/idle recommenders are **zonal** (e.g. `us-central1-a`); iterate the zones you use. The spend-based commitment recommender is **`global`** and scoped to a **billing account**.
```bash
# Rightsizing VMs (zonal — repeat per zone)
gcloud recommender recommendations list \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --project=YOUR_PROJECT --location=us-central1-a --format=json

# Idle VMs (zonal — repeat per zone)
gcloud recommender recommendations list \
  --recommender=google.compute.instance.IdleResourceRecommender \
  --project=YOUR_PROJECT --location=us-central1-a \
  --format="table(description, primaryImpact.costProjection.cost.units, stateInfo.state)"

# Committed Use Discounts (global, billing-account scoped)
gcloud recommender recommendations list \
  --recommender=google.cloudbilling.commitment.SpendBasedCommitmentRecommender \
  --billing-account=BILLING_ACCOUNT_ID --location=global --format=json
```
Other cost recommenders: `google.compute.disk.IdleResourceRecommender` (idle disks), `google.compute.address.IdleResourceRecommender` (idle IPs), `google.compute.image.IdleResourceRecommender` (idle images), `google.compute.commitment.UsageCommitmentRecommender` (resource-based CUD).

### Azure — Advisor Cost category
```bash
az advisor recommendation list \
  --category Cost \
  --query "[].{Resource: shortDescription.problem, Impact: impact, AnnualSavings: extendedProperties.annualSavingsAmount, Currency: extendedProperties.savingsCurrency}" \
  -o table

# High-impact only
az advisor recommendation list --category Cost \
  --query "[?impact=='High'].{Id:id, Resource:resourceMetadata.resourceId, Savings:extendedProperties.annualSavingsAmount}" -o json
```
`extendedProperties` fields vary by recommendation type — handle nulls.

## 3. Cost & Usage Breakdown

**AWS** (remember the ~$0.01/call cost — don't loop):
```bash
aws ce get-cost-and-usage \
  --time-period Start=$START,End=$END \
  --granularity DAILY --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

**GCP** — detailed cost/usage comes from the **BigQuery billing export** (there is no `gcloud` command for granular cost rows). Enable Billing → BigQuery export, then query `gcp_billing_export_resource_v1_<BILLING_ACCOUNT_ID>`.
> Note: as of **2026-01-21** the export schema changed — CUD discounts moved out of the `credits` array into a new `consumption_model` field, and `price.list_price` / `price.effective_price_default` were added. Update any CUD/credit logic accordingly.

**Azure** — prefer **Cost Management exports** (or the Cost Details API) for detailed data; `az consumption` is on Microsoft's deprecation path (keep only as a quick-look fallback):
```bash
# Primary: schedule/run an export to storage (one-shot needs only the 5 required params)
az costmanagement export create \
  --name AdhocExport --type Usage \
  --scope "/subscriptions/SUB_ID" \
  --storage-account-id "/subscriptions/.../storageAccounts/ACCT" \
  --storage-container exports --timeframe MonthToDate

# Fallback quick-look (deprecated API):
az consumption usage list --start-date $START --end-date $END \
  --query "[].{Resource:instanceName, Service:consumedService, Cost:pretaxCost}" -o table
```
For ad-hoc aggregation without storage, call the Cost Management **Query** REST API via `az rest` (there is no `az costmanagement query` subcommand).

## 4. Rightsizing & Compute Recommendations

**AWS — Compute Optimizer** (requires enrollment; see Pre-flight). Deep rightsizing + idle detection:
```bash
aws compute-optimizer get-ec2-instance-recommendations
aws compute-optimizer get-auto-scaling-group-recommendations
aws compute-optimizer get-ebs-volume-recommendations
aws compute-optimizer get-lambda-function-recommendations
aws compute-optimizer get-rds-database-recommendations
aws compute-optimizer get-idle-recommendations
```
Cost Explorer also offers EC2 rightsizing (`--service` is required, only `"AmazonEC2"` is valid):
```bash
aws ce get-rightsizing-recommendation --service "AmazonEC2"
```

**GCP** — machine-type recommender (note `tonumber`: GCP returns `cost.units` as a **string**):
```bash
gcloud recommender recommendations list \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --project=YOUR_PROJECT --location=us-central1-a --format=json \
  | jq '.[] | select((.primaryImpact.costProjection.cost.units|tonumber) < 0)'
```

**Azure** — Advisor Cost recommendations already include VM rightsizing / underutilized resources (section 2).

## 5. Commitments & Discounts

**AWS** — Savings Plans purchase recommendation. All four params are **required**:
```bash
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years ONE_YEAR \
  --payment-option NO_UPFRONT \
  --lookback-period-in-days THIRTY_DAYS
```
(`savings-plans-type`: `COMPUTE_SP|EC2_INSTANCE_SP|SAGEMAKER_SP`; `term-in-years`: `ONE_YEAR|THREE_YEARS`; `payment-option`: `NO_UPFRONT|PARTIAL_UPFRONT|ALL_UPFRONT`; `lookback-period-in-days`: `SEVEN_DAYS|THIRTY_DAYS|SIXTY_DAYS`.)

**GCP** — Committed Use Discounts via the spend-based commitment recommender (section 2).

**Azure** — reservation / savings-plan recommendations surface via Advisor (per-subscription); for billing-account scope use the Consumption Reservation Recommendations REST API via `az rest`:
```bash
az advisor recommendation list --category Cost \
  --query "[?contains(shortDescription.problem, 'reserved') || contains(shortDescription.problem, 'reservation')]"
```

## 6. Prioritization Template (for any provider)

When summarizing:
1. Total estimated monthly / annual savings.
2. Quick wins bucket (VeryLow/Low effort or equivalent).
3. Top 5-8 items: Resource, Current state, Recommended action, $ savings, Effort/risk.
4. Concrete next command for the top item.

```
Provider: GCP
Total potential monthly savings: $2,340

Quick wins:
- Delete idle VM ... : $180/mo (VeryLow)
- Rightsize n1-standard-8 → n2-standard-4 : $420/mo

Next command:
gcloud recommender recommendations list --recommender=google.compute.instance.IdleResourceRecommender --project=... --location=us-central1-a
```

## Provider-Specific Quick Reference

### AWS
- Cost Optimization Hub (`us-east-1`, enrolled) for the broad aggregated view.
- Compute Optimizer (enrolled) for deep rightsizing + idle.
- Cost Explorer (`aws ce`) for spend breakdowns, rightsizing, Savings Plans — mind per-call cost.

### GCP
Always pass `--location`. Key recommenders:
- MachineTypeRecommender (rightsizing, zonal)
- IdleResourceRecommender for VMs / disks / IPs / images (zonal/regional)
- SpendBasedCommitmentRecommender (CUDs, global, billing-account)

### Azure
- Advisor is the primary source for Cost recommendations.
- Cost Management **exports** (or Cost Details API) for raw usage; `az consumption` only as a deprecated fallback.

## Full Audit Flow (Recommended)

1. Authenticate; confirm enrollments (Compute Optimizer, COH).
2. Pull high-level cost summary for the window.
3. Pull recommendations (Hub / Recommender / Advisor), aggregating all pages.
4. Filter for savings > threshold and low effort.
5. Cross-check with raw usage if needed.
6. Produce prioritized list + 3 concrete next actions (read-only; flag any mutation for approval).
7. (Optional) Repeat for other providers.

## References

**AWS**
- Cost Explorer: https://docs.aws.amazon.com/cli/latest/reference/ce/
- Compute Optimizer: https://docs.aws.amazon.com/cli/latest/reference/compute-optimizer/
- Cost Optimization Hub: https://docs.aws.amazon.com/cost-management/latest/userguide/cost-optimization-hub.html
- Billing IAM action migration (aws-portal retirement): https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/migrate-granularaccess-iam-mapping-reference.html

**GCP**
- Recommenders list: https://cloud.google.com/recommender/docs/recommenders
- `recommendations list`: https://cloud.google.com/sdk/gcloud/reference/recommender/recommendations/list
- BigQuery billing export: https://cloud.google.com/billing/docs/how-to/export-data-bigquery

**Azure**
- Advisor recommendations: https://learn.microsoft.com/cli/azure/advisor/recommendation
- Cost Management exports: https://learn.microsoft.com/cli/azure/costmanagement/export
- Consumption API migration: https://learn.microsoft.com/azure/cost-management-billing/automate/migrate-consumption-usage-details-api

---

Run it with a specific provider or across all three. Stay native. Stay effective.
