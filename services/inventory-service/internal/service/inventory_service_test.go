package service

import (
	"context"
	"encoding/json"
	"github.com/gopher-opsx/cloudmart-azure/services/inventory-service/internal/domain"
	"testing"
)

type fakeRepo struct{ called bool }

func (f *fakeRepo) ReserveForOrder(context.Context, domain.EventEnvelope, domain.OrderCreatedPayload, string) error {
	f.called = true
	return nil
}
func TestHandleOrderCreated(t *testing.T) {
	raw, _ := json.Marshal(domain.OrderCreatedPayload{OrderID: "ord-1"})
	r := &fakeRepo{}
	s := New(r, "inventory")
	if err := s.HandleEvent(context.Background(), domain.EventEnvelope{EventType: domain.OrderCreated, Payload: raw}); err != nil {
		t.Fatal(err)
	}
	if !r.called {
		t.Fatal("expected repository call")
	}
}
