# Application Insights module

Creates the CloudMart training Application Insights resource.

The resource is deliberately workspace-based and reuses the existing CloudMart
Log Analytics workspace.

Training baseline:

- Application type: `web`
- Sampling: `100%`
- Daily data cap: `1 GB`
- Internet ingestion: enabled
- Internet query: enabled
- Local authentication: enabled

This module only creates the Azure telemetry destination. It does not configure
CloudMart services to export telemetry; that happens later in the course.
