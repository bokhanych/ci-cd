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
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      networks:
      - default
EOF

# Grafana-datasources
mkdir -p /etc/grafana/datasources
touch /etc/grafana/datasources/datasource.yml
cat << EOF > /etc/grafana/datasources/datasource.yml
apiVersion: 1

datasources:
- name: Prometheus
  type: prometheus
  url: http://prometheus:9090
  isDefault: true
  access: proxy
  editable: true
EOF

# Grafana-dashboards
mkdir /etc/grafana/dashboards
cat << EOF > /etc/grafana/dashboards/dashboard.yml
apiVersion: 1

providers:
- name: 'a unique provider name'
  orgId: 1
  folder: ''
  folderUid: ''
  type: file
  disableDeletion: false
  editable: true
  updateIntervalSeconds: 10
  options:
    path: /etc/grafana/provisioning/dashboards
EOF
cd /tmp && git clone https://github.com/bokhanych/ci-cd.git && cp ci-cd/grafana-dashboard/docker-url_by_bokhanych.json /etc/grafana/dashboards/ && rm -r ci-cd

# Prometheus-config
mkdir /etc/prometheus
cat << EOF > /etc/prometheus/prometheus.yml
# Set global configuration
global:
  scrape_interval:     5s
  evaluation_interval: 5s
  external_labels:
      monitor: 'my-project'
rule_files:
scrape_configs:

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
        - http://localhost:9090
        - http://localhost:3000
        - http://localhost:8080/helloworld/hello
        - http://localhost:9115

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
mkdir /etc/blackbox
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

#cd /etc/ && docker compose up -d



# CHANGE:
# cd ~ && vi mon.sh

# RUN: 
# cd ~ && bash mon.sh

# CLEAR: 
# cd /etc && docker kill $(docker ps -q) && docker system prune -a -f && rm -r /etc/grafana /etc/prometheus /etc/blackbox /etc/docker-compose.yml && rm /etc/docker/daemon.json