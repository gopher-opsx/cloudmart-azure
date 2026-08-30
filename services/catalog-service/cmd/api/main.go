package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gopher-opsx/cloudmart-azure/services/catalog-service/internal/config"
	"github.com/gopher-opsx/cloudmart-azure/services/catalog-service/internal/infrastructure/memory"
	"github.com/gopher-opsx/cloudmart-azure/services/catalog-service/internal/service"
	httptransport "github.com/gopher-opsx/cloudmart-azure/services/catalog-service/internal/transport/http"
)

func main() {
	cfg := config.Load()

	productRepository := memory.NewProductRepository()
	catalogService := service.NewCatalogService(productRepository)
	catalogHandler := httptransport.NewCatalogHandler(catalogService)

	mux := http.NewServeMux()

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	mux.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready"))
	})

	mux.HandleFunc("GET /products", catalogHandler.ListProducts)

	server := &http.Server{
		Addr:    cfg.HTTPAddr,
		Handler: mux,
	}

	mux.HandleFunc("GET /products/{id}", catalogHandler.GetProduct)

	log.Printf("catalog-service listening on %s", cfg.HTTPAddr)

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(fmt.Errorf("catalog-service failed: %w", err))
	}
}
