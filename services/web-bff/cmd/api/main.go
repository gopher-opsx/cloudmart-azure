package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/gopher-opsx/cloudmart-azure/services/web-bff/internal/config"
	"github.com/gopher-opsx/cloudmart-azure/services/web-bff/internal/httpapi"
	"github.com/gopher-opsx/cloudmart-azure/services/web-bff/internal/metrics"
)

func main() {
	cfg := config.Load()
	handler, err := httpapi.New(cfg.CatalogURL, cfg.CartURL, cfg.OrderURL, cfg.AllowedOrigin)
	if err != nil {
		log.Fatal(err)
	}
	appHandler := handler.Routes()
	metricCollector := metrics.New("web-bff")
	mux := http.NewServeMux()
	mux.Handle("/metrics", metricCollector.Handler())
	mux.Handle("/", appHandler)
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	server := &http.Server{Addr: cfg.HTTPAddr, Handler: metricCollector.Middleware(mux), ReadHeaderTimeout: 5 * time.Second}
	errorsCh := make(chan error, 1)
	go func() { log.Printf("web-bff listening on %s", cfg.HTTPAddr); errorsCh <- server.ListenAndServe() }()
	select {
	case <-ctx.Done():
		shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := server.Shutdown(shutdown); err != nil {
			log.Printf("web-bff shutdown: %v", err)
		}
	case err := <-errorsCh:
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(err)
		}
	}
}
