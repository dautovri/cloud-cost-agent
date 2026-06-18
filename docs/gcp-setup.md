# GCP Setup for Cloud Cost Agent

## Authentication
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login   # for some APIs
```

## Required Permissions (read-only for cost/recommendations)
- `recommender.*.get` and `recommender.*.list` (for all cost recommenders)
- Billing Account Viewer or Cost Management permissions
- `billing.resourceCosts.get` or project-level `roles/viewer` + billing export access

Recommended custom role or use:
- `roles/recommender.viewer`
- `roles/billing.viewer`
- BigQuery read if using billing export

## Billing Export (CUR equivalent)
1. Go to Billing → Billing export → BigQuery export.
2. Enable detailed usage cost data.
3. Note the dataset/table for queries in the agent.

## Useful Commands
See SKILL.md for the full set of `gcloud recommender` examples.

## Opt-in Notes
Most cost recommenders are on by default for projects with sufficient usage history (typically 30+ days). No explicit "enable" like AWS Compute Optimizer in most cases.