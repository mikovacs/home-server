.PHONY: setup start stop status logs clean update tunnel-setup tunnel-status tunnel-logs monitoring-setup qbittorrent-setup create-env mount help test-all validate-config test-monitoring test-scripts test-cleanup

setup:
	@echo "🏠 Setting up home server..."
	chmod +x scripts/setup.sh
	chmod +x scripts/external-hdd/*.sh
	chmod +x scripts/cloudflare/*.sh
	chmod +x scripts/monitoring/*.sh
	chmod +x scripts/qbittorrent/*.sh
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

qbittorrent-setup:
	@echo "📥 Setting up qBittorrent..."
	sudo ./scripts/qbittorrent/setup.sh

start:
	@echo "🚀 Starting services..."
	docker compose up -d

start-safe:
	@echo "🚀 Starting services safely (monitoring first)..."
	@echo "Starting monitoring stack first..."
	docker compose up -d loki prometheus node-exporter
	@echo "Waiting for Loki to be ready..."
	sleep 10
	@echo "Starting remaining services..."
	docker compose up -d

stop:
	@echo "🛑 Stopping services..."
	docker compose down

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
	docker compose logs -f

grafana-logs:
	docker compose logs -f grafana

loki-logs:
	docker compose logs -f loki

prometheus-logs:
	docker compose logs -f prometheus

qbittorrent-logs:
	docker compose logs -f qbittorrent

monitoring-logs:
	docker compose logs -f grafana loki prometheus promtail node-exporter

update:
	@echo "🔄 Updating services..."
	docker compose pull
	docker compose up -d

clean:
	@echo "🧹 Cleaning up..."
	docker compose down -v
	docker system prune -f

plex-logs:
	docker compose logs -f plex

restart-plex:
	docker compose restart plex

restart-qbittorrent:
	docker compose restart qbittorrent

start-monitoring:
	@echo "📊 Starting monitoring services..."
	docker compose up -d grafana loki promtail prometheus node-exporter

stop-monitoring:
	@echo "📊 Stopping monitoring services..."
	docker compose stop grafana loki promtail prometheus node-exporter

help:
	@echo "🏠 Home Server Commands:"
	@echo "  setup             - Initial setup and make scripts executable"
	@echo "  create-env        - Create environment file template"
	@echo "  mount             - Setup external HDD"
	@echo "  tunnel-setup      - Setup Cloudflare Tunnel"
	@echo "  monitoring-setup  - Setup monitoring stack"
	@echo "  qbittorrent-setup - Setup qBittorrent"
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
	@echo ""
	@echo "📥 qBittorrent:"
	@echo "  qbittorrent-logs    - Show qBittorrent logs"
	@echo "  restart-qbittorrent - Restart qBittorrent service"

# Test targets for CI/CD
test-all: validate-config test-monitoring test-scripts
	@echo "🎉 All tests passed!"

validate-config:
	@echo "🔍 Validating configuration..."
	docker compose config > /dev/null
	@echo "✅ Docker Compose syntax is valid"
	find scripts -name "*.sh" -exec bash -n {} \;
	@echo "✅ All scripts have valid syntax"

test-monitoring:
	@echo "🧪 Testing monitoring stack..."
	docker compose -f docker-compose.test.yml up -d
	sleep 30
	curl -f http://localhost:3000/api/health || (docker compose -f docker-compose.test.yml logs && exit 1)
	curl -f http://localhost:3100/ready || (docker compose -f docker-compose.test.yml logs && exit 1)
	curl -f http://localhost:9090/-/healthy || (docker compose -f docker-compose.test.yml logs && exit 1)
	curl -f -s http://localhost:8080 > /dev/null || (docker compose -f docker-compose.test.yml logs && exit 1)
	docker compose -f docker-compose.test.yml down -v
	@echo "✅ Monitoring stack tests passed"

test-scripts:
	@echo "🧪 Testing scripts..."
	chmod +x scripts/**/*.sh
	./scripts/create-env.sh
	test -f .env
	@echo "✅ Script tests passed"

test-cleanup:
	@echo "🧹 Cleaning up test artifacts..."
	docker compose -f docker-compose.test.yml down -v 2>/dev/null || true
	docker compose -f docker-compose.integration.yml down -v 2>/dev/null || true
	rm -f .env docker-compose.test.yml docker-compose.integration.yml
	docker system prune -f