package outbox

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/domain"
)

type fakeOutbox struct {
	events       []domain.OutboxEvent
	publishedIDs []string
	failedIDs    []string
}

func (f *fakeOutbox) ClaimBatch(_ context.Context, _ int) ([]domain.OutboxEvent, error) {
	events := f.events
	f.events = nil
	return events, nil
}

func (f *fakeOutbox) MarkPublished(_ context.Context, id string) error {
	f.publishedIDs = append(f.publishedIDs, id)
	return nil
}

func (f *fakeOutbox) RecordFailure(_ context.Context, id string) error {
	f.failedIDs = append(f.failedIDs, id)
	return nil
}

type fakeMessages struct {
	fail bool
}

func (f *fakeMessages) Publish(_ context.Context, _, _ string, _ []byte) error {
	if f.fail {
		return errors.New("kafka unavailable")
	}
	return nil
}

func TestPublishBatchMarksSuccessfulEventPublished(t *testing.T) {
	store := &fakeOutbox{
		events: []domain.OutboxEvent{
			{ID: "evt-001", Topic: "orders", EventKey: "ord-001", Payload: []byte(`{}`)},
		},
	}
	publisher := NewPublisher(store, &fakeMessages{}, time.Second, 10)

	publisher.publishBatch(context.Background())

	if len(store.publishedIDs) != 1 || store.publishedIDs[0] != "evt-001" {
		t.Fatalf("expected evt-001 published, got %#v", store.publishedIDs)
	}
	if len(store.failedIDs) != 0 {
		t.Fatalf("expected no failures, got %#v", store.failedIDs)
	}
}

func TestPublishBatchRecordsKafkaFailure(t *testing.T) {
	store := &fakeOutbox{
		events: []domain.OutboxEvent{
			{ID: "evt-002", Topic: "orders", EventKey: "ord-002", Payload: []byte(`{}`)},
		},
	}
	publisher := NewPublisher(store, &fakeMessages{fail: true}, time.Second, 10)

	publisher.publishBatch(context.Background())

	if len(store.publishedIDs) != 0 {
		t.Fatalf("expected no published events, got %#v", store.publishedIDs)
	}
	if len(store.failedIDs) != 1 || store.failedIDs[0] != "evt-002" {
		t.Fatalf("expected evt-002 failure, got %#v", store.failedIDs)
	}
}
