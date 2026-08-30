package service

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/domain"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/repository"
)

type fakeOrderRepository struct{ created domain.Order }

func (f *fakeOrderRepository) Create(_ context.Context, order domain.Order) (domain.Order, error) {
	f.created = order
	return order, nil
}
func (f *fakeOrderRepository) GetByID(_ context.Context, _ string) (domain.Order, error) {
	return domain.Order{}, repository.ErrOrderNotFound
}
func (f *fakeOrderRepository) ListByCustomer(_ context.Context, _ string) ([]domain.Order, error) {
	return nil, nil
}

func TestCreateOrderCalculatesTotalAndStartsPending(t *testing.T) {
	repo := &fakeOrderRepository{}
	svc := NewOrderService(repo)
	svc.now = func() time.Time { return time.Date(2026, 8, 31, 0, 0, 0, 0, time.UTC) }
	svc.newID = func() (string, error) { return "ord-test", nil }
	order, err := svc.CreateOrder(context.Background(), CreateOrderInput{CustomerID: "customer-001", Currency: "usd", Items: []domain.OrderItem{{ProductID: "prod-001", Quantity: 2, UnitPriceCents: 1000}, {ProductID: "prod-002", Quantity: 1, UnitPriceCents: 500}}})
	if err != nil {
		t.Fatalf("CreateOrder() error = %v", err)
	}
	if order.ID != "ord-test" {
		t.Fatalf("expected ord-test, got %s", order.ID)
	}
	if order.Status != domain.OrderStatusPending {
		t.Fatalf("expected pending, got %s", order.Status)
	}
	if order.Currency != "USD" {
		t.Fatalf("expected USD, got %s", order.Currency)
	}
	if order.TotalCents != 2500 {
		t.Fatalf("expected 2500, got %d", order.TotalCents)
	}
}

func TestCreateOrderRejectsEmptyItems(t *testing.T) {
	_, err := NewOrderService(&fakeOrderRepository{}).CreateOrder(context.Background(), CreateOrderInput{CustomerID: "customer-001", Currency: "USD"})
	if !errors.Is(err, ErrItemsRequired) {
		t.Fatalf("expected ErrItemsRequired, got %v", err)
	}
}

func TestCreateOrderRejectsInvalidQuantity(t *testing.T) {
	_, err := NewOrderService(&fakeOrderRepository{}).CreateOrder(context.Background(), CreateOrderInput{CustomerID: "customer-001", Currency: "USD", Items: []domain.OrderItem{{ProductID: "prod-001", Quantity: 0, UnitPriceCents: 1000}}})
	if !errors.Is(err, ErrInvalidQuantity) {
		t.Fatalf("expected ErrInvalidQuantity, got %v", err)
	}
}
