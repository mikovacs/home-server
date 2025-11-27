.PHONY: help start stop restart status setup-hdd logs down clean audit-security backup update

# Default target - show help
help:
	@echo "Home Server - Available Commands"
	@echo "================================="
	@echo ""
	@echo "  make start         - Configure environment and start all services"
	@echo "  make stop          - Stop all running services"
	@echo "  make restart       - Restart all services"
	@echo "  make status        - Show service and HDD status"
	@echo "  make setup-hdd     - Setup and verify external HDD structure"
	@echo "  make logs          - Show logs from all services"
	@echo "  make down          - Stop and remove all containers"
	@echo "  make clean         - Stop containers and remove volumes (WARNING: deletes data)"
	@echo "  make audit-security - Check .env security configuration"
	@echo "  make backup        - Backup configurations and .env (encrypted)"
	@echo "  make update        - Update Docker images and restart services"
	@echo ""
	@echo "For more information, see the README.md file."

# Start services (runs configuration script which starts docker-compose)
start:
	@chmod +x scripts/start.sh
	@./scripts/start.sh

# Stop services
stop:
	@docker-compose stop

# Restart services
restart:
	@docker-compose restart

# Show status
status:
	@chmod +x scripts/show-status.sh
	@./scripts/show-status.sh

# Setup external HDD
setup-hdd:
	@chmod +x scripts/setup-hdd.sh
	@./scripts/setup-hdd.sh

# Show logs
logs:
	@docker-compose logs -f

# Stop and remove containers
down:
	@docker-compose down

# Clean everything (WARNING: removes volumes)
clean:
	@echo "WARNING: This will remove all containers and volumes!"
	@read -p "Are you sure? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker-compose down -v; \
		echo "Cleanup complete."; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Security audit
audit-security:
	@chmod +x scripts/audit-env.sh
	@./scripts/audit-env.sh

backup:
	@chmod +x scripts/backup.sh
	@./scripts/backup.sh

# Update Docker images
update:
	@chmod +x scripts/update.sh
	@./scripts/update.sh
