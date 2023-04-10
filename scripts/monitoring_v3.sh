#!/bin/bash
touch /etc/docker/daemon.json
cat << EOF > /etc/docker/daemon.json
{
	"metrics-addr" : "0.0.0.0:9323",
	"experimental" : true
}
EOF
service docker restart

cat << EOF > /etc/docker-compose.yml
version: '3.7'
services:
    prometheus:
      image: prom/prometheus:latest
      container_name: prometheus
      volumes:
      - ./prometheus/:/etc/prometheus/
      command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      ports:
      - '9090:9090'
      restart: unless-stopped
      networks:
      - default
    blackbox:
      image: prom/blackbox-exporter:latest
      container_name: blackbox
      privileged: true
      depends_on:
      - prometheus
      command:
      - "--config.file=/etc/blackbox/blackbox.yml"
      volumes:
      - ./blackbox/:/etc/blackbox/
      ports:
      - '9115:9115'
      restart: unless-stopped
      networks:
      - default
    grafana:
      image: grafana/grafana:latest
      container_name: grafana
      user: "472"
      ports:
      - '3000:3000'
      restart: unless-stopped    
      environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=grafana
      volumes:
      - ./grafana:/etc/grafana/provisioning/datasources
      networks:
      - default
EOF

# Grafana-datasources
mkdir -p /etc/grafana/provisioning/datasources
cat << EOF > /etc/grafana/provisioning/datasource.yml
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
mkdir -p /etc/prometheus
cat << EOF > /etc/prometheus/prometheus.yml
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
sed -i "s%localhost%$EXTERNAL_IP%g" /etc/prometheus/prometheus.yml;

# Blackbox-config
mkdir -p /etc/blackbox
cat << EOF > /etc/blackbox/blackbox.yml
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