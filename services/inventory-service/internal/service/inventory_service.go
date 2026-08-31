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
	if e.EventType != domain.OrderCreated {
		return nil
	}
	var order domain.OrderCreatedPayload
	if err := json.Unmarshal(e.Payload, &order); err != nil {
		return fmt.Errorf("decode order.created: %w", err)
	}
	return s.repo.ReserveForOrder(ctx, e, order, s.topic)
}
