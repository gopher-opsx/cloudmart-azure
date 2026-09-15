# ADR 004 — Use Azure Event Hubs for CloudMart Messaging

## Decision

Use Azure Event Hubs with Kafka compatibility for
CloudMart asynchronous messaging.

## Event Hubs

- orders
- inventory
- payments

## Preserve

- Existing Kafka-style producers and consumers where compatible
- Existing application event contracts
- Service-specific consumer groups
- Order ID as the partition key where ordering is required

## Training design

- Standard tier
- Small training capacity
- Deliberate partition count
- Short retention
- TLS
- Controlled application access

## Why

CloudMart already uses Kafka for its event-driven order flow.

Event Hubs allows us to move messaging operations to a managed
Azure service while preserving much of the existing application model.
