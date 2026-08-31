package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/config"
	kafkainfra "github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/infrastructure/kafka"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/infrastructure/postgres"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/outbox"
	"github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/service"
	httptransport "github.com/gopher-opsx/cloudmart-azure/services/order-service/internal/transport/http"
)

func main() {
	cfg := config.Load()

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	dbPool, err := postgres.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	defer dbPool.Close()

	kafkaPublisher := kafkainfra.NewPublisher(cfg.KafkaBrokers)
	defer kafkaPublisher.Close()

	orderRepository := postgres.NewOrderRepository(dbPool, cfg.OrdersTopic)
	outboxRepository := postgres.NewOutboxRepository(dbPool)
	outboxPublisher := outbox.NewPublisher(
		outboxRepository,
		kafkaPublisher,
		cfg.OutboxPoll,
		cfg.OutboxBatchSize,
	)

	orderService := service.NewOrderService(orderRepository)
	orderHandler := httptransport.NewOrderHandler(orderService)

	go outboxPublisher.Run(ctx)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
		if err := dbPool.Ping(r.Context()); err != nil {
			http.Error(w, "database not ready", http.StatusServiceUnavailable)
			return
		}

		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready"))
	})

	mux.HandleFunc("POST /orders", orderHandler.CreateOrder)
	mux.HandleFunc("GET /orders/{id}", orderHandler.GetOrder)
	mux.HandleFunc("GET /orders", orderHandler.ListOrders)

	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	serverErrors := make(chan error, 1)
	go func() {
		log.Printf("order-service listening on %s", cfg.HTTPAddr)
		serverErrors <- server.ListenAndServe()
	}()

	select {
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if err := server.Shutdown(shutdownCtx); err != nil {
			log.Printf("order-service shutdown failed: %v", err)
		}
	case err := <-serverErrors:
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(fmt.Errorf("order-service failed: %w", err))
		}
	}
}
