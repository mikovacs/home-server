#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📊 Setting up Monitoring Stack${NC}"
echo "================================="

MONITORING_DIR="/mnt/external-hdd/monitoring"

# Create directories
echo -e "${YELLOW}Creating monitoring directories...${NC}"
sudo mkdir -p "$MONITORING_DIR"/{grafana/{data,config},loki/{data,config},promtail/config,prometheus/{data,config}}

# Set permissions
sudo chown -R 1000:1000 "$MONITORING_DIR"
sudo chmod -R 755 "$MONITORING_DIR"

# Create Loki config
echo -e "${YELLOW}Creating Loki configuration...${NC}"
cat > "$MONITORING_DIR/loki/config/local-config.yaml" << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  allow_structured_metadata: false

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  tsdb_shipper:
    active_index_directory: /loki/tsdb-index
    cache_location: /loki/tsdb-cache
    cache_ttl: 24h
  filesystem:
    directory: /loki/chunks

compactor:
  working_directory: /loki/boltdb-shipper-compactor
  shared_store: filesystem

ruler:
  storage:
    type: local
    local:
      directory: /loki/rules
  rule_path: /loki/rules
  ring:
    kvstore:
      store: inmemory
  enable_api: true
EOF

# Create Promtail config
echo -e "${YELLOW}Creating Promtail configuration...${NC}"
cat > "$MONITORING_DIR/promtail/config/config.yml" << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: containers
    static_configs:
    - targets:
        - localhost
      labels:
        job: containerlogs
        __path__: /var/lib/docker/containers/*/*log
    
    pipeline_stages:
    - json:
        expressions:
          output: log
          stream: stream
          attrs:
    - json:
        expressions:
          tag:
        source: attrs
    - regex:
        expression: (?P<container_name>(?:[^|]*))\|
        source: tag
    - timestamp:
        format: RFC3339Nano
        source: time
    - labels:
        stream:
        container_name:
    - output:
        source: output

  - job_name: syslog
    static_configs:
    - targets:
        - localhost
      labels:
        job: syslog
        __path__: /var/log/syslog
EOF

# Create Prometheus config
echo -e "${YELLOW}Creating Prometheus configuration...${NC}"
cat > "$MONITORING_DIR/prometheus/config/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 30s

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'loki'
    static_configs:
      - targets: ['loki:3100']
    metrics_path: '/metrics'
    scrape_interval: 30s
EOF

# Create Grafana provisioning
echo -e "${YELLOW}Creating Grafana provisioning...${NC}"
mkdir -p "$MONITORING_DIR/grafana/config/provisioning"/{datasources,dashboards}

cat > "$MONITORING_DIR/grafana/config/provisioning/datasources/datasources.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    isDefault: false
    jsonData:
      maxLines: 1000
EOF

cat > "$MONITORING_DIR/grafana/config/provisioning/dashboards/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    editable: true
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Create a basic system dashboard
echo -e "${YELLOW}Creating basic system dashboard...${NC}"
mkdir -p "$MONITORING_DIR/grafana/config/dashboards"

cat > "$MONITORING_DIR/grafana/config/dashboards/system-overview.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "System Overview",
    "tags": ["system"],
    "style": "dark",
    "timezone": "browser",
    "refresh": "30s",
    "schemaVersion": 30,
    "version": 1,
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent"
          }
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        }
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent"
          }
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        }
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    }
  }
}
EOF

echo -e "${GREEN}✓ Monitoring stack configuration complete${NC}"
echo -e "\nNext steps:"
echo -e "1. Add GRAFANA_PASSWORD to your .env file"
echo -e "2. Run: ${YELLOW}make stop-monitoring && make start-monitoring${NC}"
echo -e "3. Access Grafana at: ${YELLOW}http://your-pi-ip:3000${NC}"
echo -e "   Default login: admin / [your GRAFANA_PASSWORD]"
echo -e "4. Check datasource connectivity in Grafana Settings > Data Sources"