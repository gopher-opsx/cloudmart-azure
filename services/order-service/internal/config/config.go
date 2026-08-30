package config

import "os"

const (
	defaultHTTPAddr    = ":8083"
	defaultDatabaseURL = "postgres://cloudmart:cloudmart@localhost:5432/orders_db?sslmode=disable"
)

type Config struct {
	HTTPAddr    string
	DatabaseURL string
}

func Load() Config {
	return Config{
		HTTPAddr:    getEnv("HTTP_ADDR", defaultHTTPAddr),
		DatabaseURL: getEnv("DATABASE_URL", defaultDatabaseURL),
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
