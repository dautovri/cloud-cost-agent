# GCP Setup for Cloud Cost Agent

## Authentication
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login   # for some APIs
```

## Required Permissions (read-only for cost/recommendations)
Use the predefined roles (simplest):
- `roles/recommender.viewer` — read all recommenders
- `roles/billing.viewer` — billing/CUD read (grant on the billing account for spend-based CUD recommendations)
- BigQuery read on the export dataset if using billing export

If you build a **custom role**, permissions must be spelled out per recommender type — IAM does **not** accept wildcards like `recommender.*.list` in a custom role. For example:
- `recommender.computeInstanceMachineTypeRecommendations.list` / `.get`
- `recommender.computeInstanceIdleResourceRecommendations.list` / `.get`
- `recommender.spendBasedCommitmentRecommendations.list` / `.get`

## Billing Export (CUR equivalent)
1. Go to Billing → Billing export → BigQuery export.
2. Enable detailed usage cost data.
3. Note the dataset/table for queries in the agent.

## Useful Commands
See SKILL.md for the full set of `gcloud recommender` examples.

## Opt-in Notes
Most cost recommenders are on by default for projects with sufficient usage history (typically 30+ days). No explicit "enable" like AWS Compute Optimizer in most cases.