package repository

import (
	"context"
	"errors"

	"github.com/gopher-opsx/cloudmart-azure/services/catalog-service/internal/domain"
)

var ErrProductNotFound = errors.New("product not found")

type ProductRepository interface {
	List(ctx context.Context) ([]domain.Product, error)
	GetByID(ctx context.Context, id string) (domain.Product, error)
}
