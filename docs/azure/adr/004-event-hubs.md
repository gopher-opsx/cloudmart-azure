# ADR 004 — Use Azure Event Hubs Through the Kafka-Compatible Endpoint

**Status:** Accepted  
**Course scope:** CloudMart Azure training

## Context

CloudMart already uses Kafka semantics locally:

- `orders`
- `inventory`
- `payments`
- stable Kafka `group.id` values
- application-level retries, idempotency, outbox publishing, and Saga compensation

The Azure migration should preserve that application contract without adding
the operational burden of running a Kafka cluster for the course.

## Decision

Use Azure Event Hubs Standard through its Kafka-compatible endpoint.

Training baseline:

- Standard namespace
- 1 throughput unit
- auto-inflate disabled
- TLS 1.2
- public network access enabled for the disposable training environment
- three Event Hubs: `orders`, `inventory`, `payments`
- three partitions per Event Hub
- 24-hour delete retention
- scoped SAS authorization rule with Send + Listen and no Manage
- Kafka clients use `SASL_SSL` + `PLAIN`
- Kafka SASL username is `$ConnectionString`
- Kafka SASL password is the scoped Event Hubs namespace connection string

## Why

This keeps CloudMart's existing Kafka client contract while Azure operates the
messaging infrastructure.

## Trade-offs

Event Hubs is Kafka-compatible, not a self-managed Kafka cluster. Feature and
operational behavior are therefore not identical to every Kafka deployment.

The course does not depend on Kafka-specific broker administration or features
that require owning the Kafka control plane.

## Production evolution

A production design should revisit:

- private networking
- Microsoft Entra / identity-based Event Hubs authentication
- throughput-unit sizing and auto-inflate
- partition count
- retention requirements
- disaster recovery
- monitoring and alerting

The training SAS credential is intentionally scoped and must never use the
`RootManageSharedAccessKey` application-side.
