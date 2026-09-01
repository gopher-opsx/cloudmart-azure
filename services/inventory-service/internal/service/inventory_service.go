package service

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/gopher-opsx/cloudmart-azure/services/inventory-service/internal/domain"
	"github.com/gopher-opsx/cloudmart-azure/services/inventory-service/internal/repository"
)

type InventoryService struct {
	repo  repository.InventoryRepository
	topic string
}

func New(repo repository.InventoryRepository, topic string) *InventoryService {
	return &InventoryService{repo: repo, topic: topic}
}

func (s *InventoryService) HandleEvent(ctx context.Context, e domain.EventEnvelope) error {
	switch e.EventType {
	case domain.OrderCreated:
		var order domain.OrderCreatedPayload
		if err := json.Unmarshal(e.Payload, &order); err != nil {
			return fmt.Errorf("decode order.created: %w", err)
		}
		return s.repo.ReserveForOrder(ctx, e, order, s.topic)
	case domain.OrderCancelled:
		var order domain.OrderCancelledPayload
		if err := json.Unmarshal(e.Payload, &order); err != nil {
			return fmt.Errorf("decode order.cancelled: %w", err)
		}
		if order.OrderID == "" {
			order.OrderID = e.AggregateID
		}
		return s.repo.ReleaseForOrder(ctx, e, order, s.topic)
	default:
		return nil
	}
}
