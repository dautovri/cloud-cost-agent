# Azure Setup for Cloud Cost Agent

## Authentication
```bash
az login
az account list --output table
az account set --subscription "SUBSCRIPTION_ID_OR_NAME"
```

## Required Permissions
- Reader + Cost Management Reader on the subscription or management group.
- For Advisor cost recommendations: the built-in `Reader` role usually suffices.
- For detailed exports/queries: `Cost Management Reader` or `Reader` + storage access if exporting.

Managed roles:
- `Cost Management Reader`
- `Reader`

## Cost Data
- **Primary:** `az costmanagement export create` for ongoing detailed data (CUR-equivalent), or the Cost Details API for on-demand pulls.
- **Fallback only:** `az consumption usage list` — the Consumption Usage Details API is on Microsoft's deprecation path; don't build new pipelines on it.
- There is **no `az costmanagement query` CLI subcommand** — the Query capability is REST-only (call it via `az rest`).
- Advisor for most actionable cost recommendations.

## Key Commands
See the main SKILL.md for:
- `az advisor recommendation list --category Cost`
- `az costmanagement export` (and the `az rest` Query API for ad-hoc aggregation).

## Recommendations Notes
Azure Advisor Cost recommendations include VM rightsizing, idle resources, and reservation suggestions. They appear after sufficient usage data (usually days to weeks).

## Exports for Deep Analysis
```bash
az costmanagement export create \
  --name MonthlyExport \
  --type Usage \
  --scope "/subscriptions/YOUR_SUB" \
  --storage-account-id "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/..." \
  --storage-container "exports" \
  --timeframe MonthToDate
```