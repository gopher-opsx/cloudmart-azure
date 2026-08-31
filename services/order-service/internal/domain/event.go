package domain

import (
	"encoding/json"
	"time"
)

const OrderCreatedEventType = "order.created"

type EventEnvelope struct {
	EventID       string          `json:"eventId"`
	EventType     string          `json:"eventType"`
	EventVersion  int             `json:"eventVersion"`
	OccurredAt    time.Time       `json:"occurredAt"`
	AggregateID   string          `json:"aggregateId"`
	CorrelationID string          `json:"correlationId,omitempty"`
	CausationID   string          `json:"causationId,omitempty"`
	TraceParent   string          `json:"traceparent,omitempty"`
	Payload       json.RawMessage `json:"payload"`
}

type OrderCreatedPayload struct {
	OrderID    string      `json:"orderId"`
	CustomerID string      `json:"customerId"`
	Currency   string      `json:"currency"`
	TotalCents int64       `json:"totalCents"`
	Items      []OrderItem `json:"items"`
}
