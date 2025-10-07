.PHONY: setup start stop status logs clean update tunnel-setup tunnel-status tunnel-logs monitoring-setup create-env mount help

setup:
	@echo "🏠 Setting up home server..."
	chmod +x scripts/external-hdd/*.sh
	chmod +x scripts/cloudflare/*.sh
	chmod +x scripts/monitoring/*.sh
	chmod +x scripts/create-env.sh
	./scripts/setup.sh

create-env:
	@echo "🔧 Creating environment file..."
	./scripts/create-env.sh

mount:
	@echo "💾 Setting up external HDD..."
	sudo ./scripts/external-hdd/setup.sh

tunnel-setup:
	@echo "☁️ Setting up Cloudflare Tunnel..."
	./scripts/cloudflare/setup-tunnel.sh

monitoring-setup:
	@echo "📊 Setting up monitoring stack..."
	sudo ./scripts/monitoring/setup.sh

start:
	@echo "🚀 Starting services..."
	docker-compose up -d

start-safe:
	@echo "🚀 Starting services safely (monitoring first)..."
	@echo "Starting monitoring stack first..."
	docker-compose up -d loki prometheus node-exporter
	@echo "Waiting for Loki to be ready..."
	sleep 10
	@echo "Starting remaining services..."
	docker-compose up -d

stop:
	@echo "🛑 Stopping services..."
	docker-compose down

status:
	@echo "📊 Checking status..."
	./scripts/external-hdd/show-setup.sh

tunnel-status:
	@echo "☁️ Checking tunnel status..."
	./scripts/cloudflare/manage-tunnel.sh status

tunnel-logs:
	@echo "☁️ Showing tunnel logs..."
	./scripts/cloudflare/manage-tunnel.sh logs

tunnel-restart:
	@echo "☁️ Restarting tunnel..."
	./scripts/cloudflare/manage-tunnel.sh restart

logs:
	@echo "📋 Showing logs..."
	docker-compose logs -f

grafana-logs:
	docker-compose logs -f grafana

loki-logs:
	docker-compose logs -f loki

prometheus-logs:
	docker-compose logs -f prometheus

monitoring-logs:
	docker-compose logs -f grafana loki prometheus promtail node-exporter

update:
	@echo "🔄 Updating services..."
	docker-compose pull
	docker-compose up -d

clean:
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f

plex-logs:
	docker-compose logs -f plex

restart-plex:
	docker-compose restart plex

start-monitoring:
	@echo "📊 Starting monitoring services..."
	docker-compose up -d grafana loki promtail prometheus node-exporter

stop-monitoring:
	@echo "📊 Stopping monitoring services..."
	docker-compose stop grafana loki promtail prometheus node-exporter

help:
	@echo "🏠 Home Server Commands:"
	@echo "  setup             - Initial setup and make scripts executable"
	@echo "  create-env        - Create environment file template"
	@echo "  mount             - Setup external HDD"
	@echo "  tunnel-setup      - Setup Cloudflare Tunnel"
	@echo "  monitoring-setup  - Setup monitoring stack"
	@echo "  start             - Start all services"
	@echo "  start-safe        - Start services with proper order"
	@echo "  stop              - Stop all services"
	@echo "  status            - Show system status"
	@echo "  logs              - Show all logs"
	@echo "  update            - Update and restart services"
	@echo "  clean             - Clean up containers and images"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  start-monitoring  - Start monitoring services only"
	@echo "  monitoring-logs   - Show monitoring logs"
	@echo "  grafana-logs      - Show Grafana logs"
	@echo "  loki-logs         - Show Loki logs"
	@echo "  prometheus-logs   - Show Prometheus logs"
	@echo ""
	@echo "☁️ Tunnel:"
	@echo "  tunnel-status     - Show tunnel status"
	@echo "  tunnel-logs       - Show tunnel logs"
	@echo "  tunnel-restart    - Restart tunnel"
	@echo ""
	@echo "🎬 Plex:"
	@echo "  plex-logs         - Show Plex logs"
	@echo "  restart-plex      - Restart Plex service"