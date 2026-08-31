.PHONY: help status \
        catalog-build catalog-run \
        cart-build cart-run \
        order-build order-run \
        build

BIN_DIR := bin

help:
	@echo "CloudMart development commands"
	@echo ""
	@echo "  make build          Build all Go services"
	@echo "  make catalog-build  Build catalog service"
	@echo "  make catalog-run    Run catalog service"
	@echo "  make cart-build     Build cart service"
	@echo "  make cart-run       Run cart service"
	@echo "  make order-build    Build order service"
	@echo "  make order-run      Run order service"
	@echo "  make status         Show repository status"

status:
	git status --short

build: catalog-build cart-build order-build

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

catalog-build: $(BIN_DIR)
	go build -o $(BIN_DIR)/catalog-service.exe ./services/catalog-service/cmd/api

catalog-run: catalog-build
	./$(BIN_DIR)/catalog-service.exe

cart-build: $(BIN_DIR)
	go build -o $(BIN_DIR)/cart-service.exe ./services/cart-service/cmd/api

cart-run: cart-build
	./$(BIN_DIR)/cart-service.exe

order-build: $(BIN_DIR)
	go build -o $(BIN_DIR)/order-service.exe ./services/order-service/cmd/api

order-run: order-build
	./$(BIN_DIR)/order-service.exe
