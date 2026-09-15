# ADR 002 — Use PostgreSQL Flexible Server

## Decision

Use Azure Database for PostgreSQL Flexible Server
for CloudMart relational data.

## Training design

- One PostgreSQL Flexible Server
- Separate service-owned databases
- Burstable compute
- Small supported training SKU
- TLS required
- Protected database credentials
- Seven-day backup retention
- High availability disabled

## Service-owned databases

- Catalog → catalog_db
- Order → orders_db
- Inventory → inventory_db
- Payment → payments_db
- Notification → notifications_db

## Why

CloudMart already uses PostgreSQL.

Using Flexible Server preserves the existing database
model while moving database platform operations to
a managed Azure service.
