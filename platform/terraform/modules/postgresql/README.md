# PostgreSQL Flexible Server module

Creates the CloudMart training PostgreSQL platform.

The module deliberately separates three course stages:

1. server creation
2. narrow administration firewall access
3. service-owned logical databases

Application tables and seed data are not Terraform resources. They remain
owned by the SQL migrations stored with each CloudMart service.
