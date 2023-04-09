#!/bin/bash
touch /etc/docker/daemon.json
cat << EOF > /etc/docker/daemon.json
{
	"metrics-addr" : "0.0.0.0:9323",
	"experimental" : true
}
EOF
service docker restart

mkdir /etc/monitoring/
cat << EOF > /etc/monitoring/docker-compose.yml
version: '3.7'
services:
    prometheus:
      image: prom/prometheus:latest
      container_name: prometheus
      volumes:
      - ./prometheus/:/etc/monitoring/prometheus/
      command:
      - '--config.file=/etc/monitoring/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      ports:
      - '9090:9090'
      restart: unless-stopped
    blackbox:
      image: prom/blackbox-exporter:latest
      container_name: blackbox
      privileged: true
      command:
      - "--config.file=/etc/monitoring/blackbox/blackbox.yml"
      volumes:
      - ./blackbox/:/etc/monitoring/blackbox/
      ports:
      - '9115:9115'
      restart: unless-stopped
    grafana:
      image: grafana/grafana:latest
      container_name: grafana
      user: "472"
      depends_on:
      - prometheus
      ports:
      - '3000:3000'
      restart: unless-stopped    
      environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=grafana
      volumes:
      - ./grafana:/etc/monitoring/grafana
volumes:
  prom_data:
EOF

# Grafana-datasources
mkdir -p /etc/monitoring/grafana
cat << EOF > /etc/monitoring/grafana/datasource.yml
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  url: http://prometheus:9090
  isDefault: true
  access: proxy
  editable: true
EOF

# Prometheus-config
mkdir -p /etc/monitoring/prometheus
cat << EOF > /etc/monitoring/prometheus/prometheus.yml
# Set global configuration
global:
  scrape_interval:     15s
  evaluation_interval: 15s
  external_labels:
      monitor: 'my-project'
rule_files:
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
         - targets: ['prometheus:9090']
  - job_name: 'docker-metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['172.17.0.1:9323'] 
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://localhost:8080/helloworld/hello
        - http://prometheus:9090
        - http://grafana:3000
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox:9115
EOF

EXTERNAL_IP=$(hostname  -I | cut -f1 -d' ');
sed -i "s%localhost%$EXTERNAL_IP%g" /etc/monitoring/prometheus/prometheus.yml;

# Blackbox-config
mkdir -p /etc/monitoring/blackbox
cat << EOF > /etc/monitoring/blackbox/blackbox.yml
modules:
  http_2xx:
    http:
      no_follow_redirects: false
      preferred_ip_protocol: ip4
      valid_http_versions:
      - HTTP/1.1
      - HTTP/2.0
      valid_status_codes: []
    prober: http
    timeout: 5s
EOF



cd /etc/monitoring && docker compose up -d