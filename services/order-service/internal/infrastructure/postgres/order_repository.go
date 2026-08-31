package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/domain"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/repository"
)

type OrderRepository struct {
	pool        *pgxpool.Pool
	ordersTopic string
}

func NewOrderRepository(pool *pgxpool.Pool, ordersTopic string) *OrderRepository {
	return &OrderRepository{
		pool:        pool,
		ordersTopic: ordersTopic,
	}
}

func (r *OrderRepository) Create(ctx context.Context, order domain.Order) (domain.Order, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return domain.Order{}, fmt.Errorf("begin create order transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx, `
		INSERT INTO orders (
			id,
			customer_id,
			status,
			currency,
			total_cents,
			created_at,
			updated_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`,
		order.ID,
		order.CustomerID,
		order.Status,
		order.Currency,
		order.TotalCents,
		order.CreatedAt,
		order.UpdatedAt,
	)
	if err != nil {
		return domain.Order{}, fmt.Errorf("insert order: %w", err)
	}

	for lineNumber, item := range order.Items {
		_, err = tx.Exec(ctx, `
			INSERT INTO order_items (
				order_id,
				line_number,
				product_id,
				quantity,
				unit_price_cents
			)
			VALUES ($1, $2, $3, $4, $5)
		`,
			order.ID,
			lineNumber+1,
			item.ProductID,
			item.Quantity,
			item.UnitPriceCents,
		)
		if err != nil {
			return domain.Order{}, fmt.Errorf("insert order item: %w", err)
		}
	}

	eventPayload, err := buildOrderCreatedEnvelope(order)
	if err != nil {
		return domain.Order{}, err
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO outbox_events (
			id,
			topic,
			event_key,
			event_type,
			payload,
			created_at
		)
		VALUES ($1, $2, $3, $4, $5::jsonb, $6)
	`,
		newOutboxID(order.ID),
		r.ordersTopic,
		order.ID,
		domain.OrderCreatedEventType,
		eventPayload,
		order.CreatedAt,
	)
	if err != nil {
		return domain.Order{}, fmt.Errorf("insert outbox event: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return domain.Order{}, fmt.Errorf("commit create order transaction: %w", err)
	}

	return order, nil
}

func buildOrderCreatedEnvelope(order domain.Order) ([]byte, error) {
	payload, err := json.Marshal(domain.OrderCreatedPayload{
		OrderID:    order.ID,
		CustomerID: order.CustomerID,
		Currency:   order.Currency,
		TotalCents: order.TotalCents,
		Items:      order.Items,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal order created payload: %w", err)
	}

	envelope := domain.EventEnvelope{
		EventID:      newOutboxID(order.ID),
		EventType:    domain.OrderCreatedEventType,
		EventVersion: 1,
		OccurredAt:   order.CreatedAt,
		AggregateID:  order.ID,
		Payload:      payload,
	}

	encoded, err := json.Marshal(envelope)
	if err != nil {
		return nil, fmt.Errorf("marshal order created envelope: %w", err)
	}
	return encoded, nil
}

func newOutboxID(orderID string) string {
	return orderID + "-created"
}

func (r *OrderRepository) GetByID(ctx context.Context, id string) (domain.Order, error) {
	var order domain.Order

	err := r.pool.QueryRow(ctx, `
		SELECT
			id,
			customer_id,
			status,
			currency,
			total_cents,
			created_at,
			updated_at
		FROM orders
		WHERE id = $1
	`, id).Scan(
		&order.ID,
		&order.CustomerID,
		&order.Status,
		&order.Currency,
		&order.TotalCents,
		&order.CreatedAt,
		&order.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return domain.Order{}, repository.ErrOrderNotFound
		}
		return domain.Order{}, fmt.Errorf("get order: %w", err)
	}

	items, err := r.loadItems(ctx, order.ID)
	if err != nil {
		return domain.Order{}, err
	}
	order.Items = items

	return order, nil
}

func (r *OrderRepository) ListByCustomer(ctx context.Context, customerID string) ([]domain.Order, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			id,
			customer_id,
			status,
			currency,
			total_cents,
			created_at,
			updated_at
		FROM orders
		WHERE customer_id = $1
		ORDER BY created_at DESC
	`, customerID)
	if err != nil {
		return nil, fmt.Errorf("list orders: %w", err)
	}
	defer rows.Close()

	orders := make([]domain.Order, 0)

	for rows.Next() {
		var order domain.Order

		if err := rows.Scan(
			&order.ID,
			&order.CustomerID,
			&order.Status,
			&order.Currency,
			&order.TotalCents,
			&order.CreatedAt,
			&order.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan order: %w", err)
		}

		orders = append(orders, order)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate orders: %w", err)
	}

	for i := range orders {
		items, err := r.loadItems(ctx, orders[i].ID)
		if err != nil {
			return nil, err
		}
		orders[i].Items = items
	}

	return orders, nil
}

func (r *OrderRepository) loadItems(ctx context.Context, orderID string) ([]domain.OrderItem, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT
			product_id,
			quantity,
			unit_price_cents
		FROM order_items
		WHERE order_id = $1
		ORDER BY line_number
	`, orderID)
	if err != nil {
		return nil, fmt.Errorf("list order items: %w", err)
	}
	defer rows.Close()

	items := make([]domain.OrderItem, 0)

	for rows.Next() {
		var item domain.OrderItem
		if err := rows.Scan(
			&item.ProductID,
			&item.Quantity,
			&item.UnitPriceCents,
		); err != nil {
			return nil, fmt.Errorf("scan order item: %w", err)
		}

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate order items: %w", err)
	}

	return items, nil
}
