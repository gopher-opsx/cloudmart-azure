package repository

import (
	"context"
	"github.com/gopher-opsx/cloudmart-azure/services/inventory-service/internal/domain"
)

type InventoryRepository interface {
	ReserveForOrder(context.Context, domain.EventEnvelope, domain.OrderCreatedPayload, string) error
}

type OutboxRepository interface {
	LoadBatch(context.Context, int) ([]domain.OutboxEvent, error)
	MarkPublished(context.Context, string) error
	RecordFailure(context.Context, string) error
}
