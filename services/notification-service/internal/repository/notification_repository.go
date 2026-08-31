package repository

import (
	"context"
	"github.com/gopher-opsx/cloudmart-azure/services/notification-service/internal/domain"
)

type NotificationRepository interface {
	StoreDelivered(ctx context.Context, event domain.EventEnvelope, notification domain.Notification) (bool, error)
}
