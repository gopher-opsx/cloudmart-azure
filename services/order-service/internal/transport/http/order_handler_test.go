package httptransport

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/domain"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/repository"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/service"
)

type handlerOrderRepository struct{ order domain.Order }

func (r *handlerOrderRepository) Create(_ context.Context, order domain.Order) (domain.Order, error) {
	r.order = order
	return order, nil
}
func (r *handlerOrderRepository) GetByID(_ context.Context, id string) (domain.Order, error) {
	if r.order.ID != id {
		return domain.Order{}, repository.ErrOrderNotFound
	}
	return r.order, nil
}
func (r *handlerOrderRepository) ListByCustomer(_ context.Context, customerID string) ([]domain.Order, error) {
	if r.order.CustomerID != customerID {
		return []domain.Order{}, nil
	}
	return []domain.Order{r.order}, nil
}

func TestCreateOrderRequiresCustomerHeader(t *testing.T) {
	h := NewOrderHandler(service.NewOrderService(&handlerOrderRepository{}))
	req := httptest.NewRequest(http.MethodPost, "/orders", strings.NewReader(`{"currency":"USD","items":[{"productId":"prod-001","quantity":1,"unitPriceCents":1000}]}`))
	res := httptest.NewRecorder()
	h.CreateOrder(res, req)
	if res.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", res.Code)
	}
}

func TestCreateOrderReturnsCreated(t *testing.T) {
	h := NewOrderHandler(service.NewOrderService(&handlerOrderRepository{}))
	req := httptest.NewRequest(http.MethodPost, "/orders", strings.NewReader(`{"currency":"USD","items":[{"productId":"prod-001","quantity":2,"unitPriceCents":1000}]}`))
	req.Header.Set(customerIDHeader, "customer-001")
	res := httptest.NewRecorder()
	h.CreateOrder(res, req)
	if res.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d body=%s", res.Code, res.Body.String())
	}
	if !strings.Contains(res.Body.String(), `"status":"pending"`) {
		t.Fatalf("unexpected body: %s", res.Body.String())
	}
	if !strings.Contains(res.Body.String(), `"totalCents":2000`) {
		t.Fatalf("unexpected body: %s", res.Body.String())
	}
}
