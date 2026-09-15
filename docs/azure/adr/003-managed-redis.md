# ADR 003 — Use Azure Managed Redis

## Decision

Use Azure Managed Redis for CloudMart Cart Service state.

## Training design

- Azure Managed Redis
- Balanced tier
- Small supported training size
- Preserve compatibility with the existing Redis client
- Secure connections
- Protect sensitive access values

## Why

CloudMart already uses Redis for temporary cart state.

Using Azure Managed Redis preserves that application model
while moving Redis platform operations to a managed Azure service.

Durable business data remains in PostgreSQL.
