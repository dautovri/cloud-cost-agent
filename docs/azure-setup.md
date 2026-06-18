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
- Use `az consumption usage list` for quick usage.
- Create exports with `az costmanagement export create` for ongoing detailed data (like CUR).
- Advisor for most actionable cost recommendations.

## Key Commands
See the main SKILL.md for:
- `az advisor recommendation list --category Cost`
- `az costmanagement` and consumption queries.

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