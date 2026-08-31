package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/domain"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/repository"
)

var ErrUnsupportedPaymentEvent = errors.New("unsupported payment event")

type PaymentEventService struct {
	orders      repository.OrderRepository
	ordersTopic string
}

func NewPaymentEventService(
	orders repository.OrderRepository,
	ordersTopic string,
) *PaymentEventService {
	return &PaymentEventService{
		orders:      orders,
		ordersTopic: ordersTopic,
	}
}

func (s *PaymentEventService) HandleEvent(
	ctx context.Context,
	envelope domain.EventEnvelope,
) error {
	switch envelope.EventType {
	case domain.PaymentAuthorizedEventType:
		var payload domain.PaymentAuthorizedPayload
		if err := json.Unmarshal(envelope.Payload, &payload); err != nil {
			return fmt.Errorf("decode payment.authorized payload: %w", err)
		}
		return s.orders.ApplyPaymentEvent(
			ctx,
			envelope,
			payload.OrderID,
			payload.PaymentID,
			domain.OrderStatusConfirmed,
			"",
			s.ordersTopic,
		)

	case domain.PaymentFailedEventType:
		var payload domain.PaymentFailedPayload
		if err := json.Unmarshal(envelope.Payload, &payload); err != nil {
			return fmt.Errorf("decode payment.failed payload: %w", err)
		}
		return s.orders.ApplyPaymentEvent(
			ctx,
			envelope,
			payload.OrderID,
			payload.PaymentID,
			domain.OrderStatusCancelled,
			payload.Reason,
			s.ordersTopic,
		)

	default:
		return ErrUnsupportedPaymentEvent
	}
}
