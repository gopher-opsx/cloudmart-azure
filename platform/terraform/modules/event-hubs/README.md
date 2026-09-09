# Event Hubs module

Creates the CloudMart Event Hubs namespace and progressively adds the
Kafka-compatible messaging resources used by the course.

Course progression:

- Lesson 47: namespace only
- Lesson 48: `orders`, `inventory`, and `payments` Event Hubs
- Lesson 49: runtime consumer-group contract validation only
- Lesson 50: scoped namespace SAS authorization rule (`Send` + `Listen`)

The namespace uses Standard tier, one throughput unit, TLS 1.2, public network
access for the training environment, and SAS authentication for Kafka
compatibility.

The application credential is deliberately not the automatically-created root
management credential.
