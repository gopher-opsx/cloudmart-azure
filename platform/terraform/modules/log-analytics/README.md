# Log Analytics module

Creates the shared Log Analytics workspace used by the CloudMart Azure training environment.

The training root module supplies the workspace name, location, retention period, daily ingestion cap, and common tags. The module deliberately owns only the workspace; Container Apps Environment and Application Insights integration are added in later lessons.

## Training baseline

- SKU: `PerGB2018`
- Retention: `30` days
- Daily ingestion cap: `1` GB
- Public query/ingestion settings: Azure provider defaults for this course environment
