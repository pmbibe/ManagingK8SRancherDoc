9.10.4.2. Monitoring Server with Prometheus and Grafana
In this tutorial, we will talk about Prometheus and Grafana. You will learn to install both on CentOS/RHEL and understand how to use Prometheus and Grafana to monitor the Linux server.
•	Grafana is a leading time-series, an open-source platform for visualization and monitoring. It allows you to query, visualize, set alerts, and understand metrics no matter where they are stored. You can create amazing dashboards in Grafana to visualize and monitor the metrics.
•	Prometheus is an open-source time-series monitoring system for machine-centric and highly dynamic service-oriented architectures. It can literally monitor everything. It integrates with Grafana very smoothly as Grafana also offers Prometheus as one of its data sources.
•	node_exporter is an official package that should be installed on Linux servers to be monitored. It exposes multiple hardware and OS metrics, which will be pulled by Prometheus and eventually visualized on Grafana.
The first, we install node_exporter on Server monitored.
installNodeExporter.sh 
#!/bin/bash
cat /etc/passwd | grep prometheus> /dev/null
if [ $? -eq 0 ]
then
  echo "User prometheus exists"
else
  useradd -m -s /bin/bash prometheus
fi
cd /home/prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.0.1.linux-amd64.tar.gz
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=node_exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/home/prometheus/node_exporter-1.0.1.linux-amd64/node_exporter
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

Futher, we can use the same Prometheus data source for storing metrics of external Servers. However, we will use other Prometheus data source to do that.
Create Endpoints, Service and ServiceMonitor for external Server.
Service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: expose-cmcglobals-metrics
  namespace: cattle-prometheus
  labels:
    k8s-app: cmcglobal
    monitoring.coreos.com: "true"
spec:
  type: ClusterIP
  ports:
  - name: metrics
    port: 9100
    protocol: TCP
  selector:
    k8s-app: cmcglobal
    monitoring.coreos.com: "true"
Endpoints.yaml 
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    k8s-app: cmcglobal
    monitoring.coreos.com: "true"
  name: expose-cmcglobals-metrics
  namespace: cattle-prometheus
subsets:
- addresses:
  - ip: 192.168.67.72
  - ip: 192.168.67.73
  - ip: 192.168.67.74
  ports:
  - name: metrics
    port: 9100
    protocol: TCP
ServiceMonitor.yaml 
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: exporter-cmcglobal
  name: exporter-cmcglobal-cluster-monitoring
  namespace: cattle-prometheus
spec:
  endpoints:
  - port: metrics
    interval: 30s
    scheme: http
  namespaceSelector:
    matchNames:
    - cattle-prometheus
  selector:
    matchLabels:
      k8s-app: cmcglobal
      monitoring.coreos.com: "true"
Finally, You apply these configs.
kubectl apply -f Service.yaml
kubectl apply -f Endpoints.yaml
kubectl apply -f ServiceMonitor.yaml
You have to wait some minutes, or you can redeploy by running this command:
kubectl rollout restart statefulset.apps/prometheus-cluster-monitoring -n cattle-prometheus
This is Dashboard config file.
MonitorHardwareServerExternal.json 
{
    "annotations": {
      "list": [
        {
          "builtIn": 1,
          "datasource": "-- Grafana --",
          "enable": true,
          "hide": true,
          "iconColor": "rgba(0, 211, 255, 1)",
          "name": "Annotations & Alerts",
          "type": "dashboard"
        }
      ]
    },
    "editable": true,
    "gnetId": null,
    "graphTooltip": 0,
    "id": 3,
    "iteration": 1610939722166,
    "links": [],
    "panels": [
      {
        "datasource": "Prometheus",
        "description": "Busy state of all CPU cores together (1 min average)",
        "fieldConfig": {
          "defaults": {
            "custom": {},
            "mappings": [
              {
                "from": "",
                "id": 0,
                "text": "0",
                "to": "",
                "type": 1,
                "value": "null"
              }
            ],
            "thresholds": {
              "mode": "percentage",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 80
                },
                {
                  "color": "red",
                  "value": 90
                }
              ]
            },
            "unit": "%"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 0,
          "y": 0
        },
        "id": 6,
        "maxDataPoints": 100,
        "options": {
          "reduceOptions": {
            "calcs": [
              "mean"
            ],
            "fields": "",
            "values": false
          },
          "showThresholdLabels": false,
          "showThresholdMarkers": true
        },
        "pluginVersion": "7.1.5",
        "targets": [
          {
            "expr": "avg(node_load1{instance=~\"$node\"}) / count(node_cpu_seconds_total{mode=\"system\",instance=~\"$node\"}) * 100",
            "interval": "",
            "legendFormat": "",
            "refId": "A"
          }
        ],
        "timeFrom": null,
        "timeShift": null,
        "title": "CPU System Load Current",
        "type": "gauge"
      },
      {
        "datasource": "Prometheus",
        "description": "Non available RAM memory",
        "fieldConfig": {
          "defaults": {
            "custom": {},
            "mappings": [
              {
                "from": "",
                "id": 0,
                "text": "0",
                "to": "",
                "type": 1,
                "value": "null"
              }
            ],
            "thresholds": {
              "mode": "percentage",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 80
                },
                {
                  "color": "red",
                  "value": 90
                }
              ]
            },
            "unit": "%"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 6,
          "y": 0
        },
        "id": 4,
        "maxDataPoints": 100,
        "options": {
          "reduceOptions": {
            "calcs": [
              "mean"
            ],
            "fields": "",
            "values": false
          },
          "showThresholdLabels": false,
          "showThresholdMarkers": true
        },
        "pluginVersion": "7.1.5",
        "targets": [
          {
            "expr": "100 - ((node_memory_MemAvailable_bytes{instance=~\"^$node\"} * 100) / node_memory_MemTotal_bytes{instance=~\"^$node\"})",
            "interval": "",
            "legendFormat": " ",
            "refId": "A"
          }
        ],
        "timeFrom": null,
        "timeShift": null,
        "title": "Used RAM Memory Current",
        "type": "gauge"
      },
      {
        "datasource": "Prometheus",
        "description": "Busy state of all CPU cores together",
        "fieldConfig": {
          "defaults": {
            "custom": {},
            "mappings": [
              {
                "from": "",
                "id": 0,
                "text": "Node",
                "to": "",
                "type": 1,
                "value": "192.168.67.79:9796"
              }
            ],
            "thresholds": {
              "mode": "percentage",
              "steps": [
                {
                  "color": "blue",
                  "value": null
                }
              ]
            },
            "unit": "none"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 12,
          "y": 0
        },
        "id": 2,
        "maxDataPoints": 100,
        "options": {
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": [
              "mean"
            ],
            "fields": "",
            "values": false
          },
          "textMode": "auto"
        },
        "pluginVersion": "7.1.5",
        "targets": [
          {
            "expr": "count(node_cpu_seconds_total{mode=\"system\",instance=~\"^$node\"})",
            "instant": true,
            "interval": "",
            "legendFormat": " ",
            "refId": "A"
          }
        ],
        "timeFrom": null,
        "timeShift": null,
        "title": "CPU Cores",
        "type": "stat"
      },
      {
        "datasource": "Prometheus",
        "description": "System uptime",
        "fieldConfig": {
          "defaults": {
            "custom": {},
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "blue",
                  "value": null
                }
              ]
            },
            "unit": "s"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 6,
          "x": 18,
          "y": 0
        },
        "id": 14,
        "options": {
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": [
              "mean"
            ],
            "fields": "",
            "values": false
          },
          "textMode": "auto"
        },
        "pluginVersion": "7.1.5",
        "targets": [
          {
            "expr": "node_time_seconds{instance=~\"^$node\"} - node_boot_time_seconds{instance=~\"^$node\"}",
            "instant": true,
            "interval": "",
            "legendFormat": "",
            "refId": "A"
          }
        ],
        "timeFrom": null,
        "timeShift": null,
        "title": "Uptime",
        "type": "stat"
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 0,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 8
        },
        "hiddenSeries": false,
        "id": 20,
        "legend": {
          "avg": false,
          "current": false,
          "max": false,
          "min": false,
          "show": true,
          "total": false,
          "values": false
        },
        "lines": true,
        "linewidth": 1,
        "nullPointMode": "null",
        "percentage": false,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "node_memory_MemTotal_bytes{instance=~\"^$node\"}",
            "interval": "",
            "legendFormat": "RAM Total",
            "refId": "A"
          },
          {
            "expr": "node_memory_MemTotal_bytes{instance=~\"^$node\"} - node_memory_MemFree_bytes{instance=~\"^$node\"} - (node_memory_Cached_bytes{instance=~\"^$node\"} + node_memory_Buffers_bytes{instance=~\"^$node\"})",
            "interval": "",
            "legendFormat": "RAM Used",
            "refId": "B"
          },
          {
            "expr": "node_memory_Cached_bytes{instance=~\"^$node\"} + node_memory_Buffers_bytes{instance=~\"^$node\"}",
            "interval": "",
            "legendFormat": "RAM Cache + Buffer",
            "refId": "C"
          },
          {
            "expr": "node_memory_MemAvailable_bytes{instance=~\"^$node\"}",
            "interval": "",
            "legendFormat": "RAM Available",
            "refId": "D"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "Memory Basic",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "bytes",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 0,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 8
        },
        "hiddenSeries": false,
        "id": 18,
        "legend": {
          "avg": false,
          "current": false,
          "max": false,
          "min": false,
          "show": false,
          "total": false,
          "values": false
        },
        "lines": true,
        "linewidth": 1,
        "nullPointMode": "null",
        "percentage": false,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "(node_load5{instance=~\"$node\"})",
            "interval": "",
            "legendFormat": "",
            "refId": "A"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "System Load",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 0,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 16
        },
        "hiddenSeries": false,
        "id": 22,
        "legend": {
          "alignAsTable": true,
          "avg": true,
          "current": true,
          "hideZero": true,
          "max": true,
          "min": true,
          "show": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "nullPointMode": "null",
        "percentage": false,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "irate(node_disk_reads_completed_total{instance=~\"^$node\",device=~\"[a-z]*[a-z]\"}[5m])",
            "interval": "",
            "legendFormat": "{{device}} - Reads completed",
            "refId": "A"
          },
          {
            "expr": "irate(node_disk_writes_completed_total{instance=~\"^$node\",device=~\"[a-z]*[a-z]\"}[5m])",
            "interval": "",
            "legendFormat": "{{device}} - Writes completed",
            "refId": "B"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "Disk IOps",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "iops",
            "label": "IO read (-) / write (+)",
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "decimals": 3,
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 0,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 16
        },
        "hiddenSeries": false,
        "id": 24,
        "legend": {
          "alignAsTable": true,
          "avg": true,
          "current": true,
          "max": true,
          "min": true,
          "show": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "nullPointMode": "null",
        "percentage": false,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "irate(node_disk_read_bytes_total{instance=~\"^$node\", device!~\"HarddiskVolume.+\"}[5m])",
            "interval": "",
            "legendFormat": "{{device}} - Successfully read bytes",
            "refId": "A"
          },
          {
            "expr": "irate(node_disk_written_bytes_total{instance=~\"^$node\", device!~\"HarddiskVolume.+\"}[5m])",
            "interval": "",
            "legendFormat": "{{device}} - Successfully written bytes",
            "refId": "B"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "I/O Usage Read / Write",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "bytes",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "ms",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "fieldConfig": {
          "defaults": {
            "custom": {
              "align": null
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            },
            "unit": "gbytes"
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 5,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 24
        },
        "hiddenSeries": false,
        "id": 12,
        "legend": {
          "alignAsTable": false,
          "avg": false,
          "current": true,
          "hideEmpty": false,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "maxDataPoints": 100,
        "nullPointMode": "null as zero",
        "percentage": true,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": true,
        "steppedLine": false,
        "targets": [
          {
            "expr": "(sum(node_filesystem_size_bytes{device!~\"rootfs|HarddiskVolume.+\",instance=~\"^$node\"})/1024/1024/1024) - (sum(node_filesystem_free_bytes{device!~\"rootfs|HarddiskVolume.+\",instance=~\"^$node\"})/1024/1024/1024)",
            "hide": false,
            "interval": "",
            "legendFormat": "Disk space used",
            "refId": "A"
          },
          {
            "expr": "(sum(node_filesystem_free_bytes{device!~\"rootfs|HarddiskVolume.+\",instance=~\"^$node\"})/1024/1024/1024)",
            "hide": false,
            "interval": "",
            "legendFormat": "Disk space free",
            "refId": "B"
          },
          {
            "expr": "(sum(node_filesystem_size_bytes{device!~\"rootfs|HarddiskVolume.+\",instance=~\"^$node\"})/1024/1024/1024)",
            "interval": "",
            "legendFormat": "Total disk",
            "refId": "C"
          }
        ],
        "thresholds": [
          {
            "colorMode": "critical",
            "fill": false,
            "line": true,
            "op": "gt",
            "value": 80,
            "yaxis": "left"
          }
        ],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "Disk space",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "gbytes",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "Prometheus",
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fill": 1,
        "fillGradient": 0,
        "gridPos": {
          "h": 11,
          "w": 12,
          "x": 12,
          "y": 24
        },
        "hiddenSeries": false,
        "id": 16,
        "legend": {
          "alignAsTable": true,
          "avg": true,
          "current": true,
          "max": true,
          "min": true,
          "rightSide": false,
          "show": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "nullPointMode": "null",
        "percentage": false,
        "pluginVersion": "7.1.5",
        "pointradius": 2,
        "points": false,
        "renderer": "flot",
        "seriesOverrides": [],
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "(node_filesystem_size_bytes{instance=~\"^$node\",device!~'rootfs'} - node_filesystem_avail_bytes{instance=~\"^$node\",device!~'rootfs'})",
            "instant": false,
            "interval": "",
            "legendFormat": "{{mountpoint}}",
            "refId": "A"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeRegions": [],
        "timeShift": null,
        "title": "Disk Space Used",
        "tooltip": {
          "shared": true,
          "sort": 0,
          "value_type": "individual"
        },
        "type": "graph",
        "xaxis": {
          "buckets": null,
          "mode": "time",
          "name": null,
          "show": true,
          "values": []
        },
        "yaxes": [
          {
            "format": "bytes",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          },
          {
            "format": "short",
            "label": null,
            "logBase": 1,
            "max": null,
            "min": null,
            "show": true
          }
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      }
    ],
    "schemaVersion": 26,
    "style": "dark",
    "tags": [
      "DU12"
    ],
    "templating": {
      "list": [
        {
          "allValue": null,
          "current": {
            "selected": false,
            "text": "192.168.67.72:9100",
            "value": "192.168.67.72:9100"
          },
          "datasource": "RANCHER_MONITORING",
          "definition": "label_values(node_load1, instance)",
          "hide": 0,
          "includeAll": false,
          "label": "Host",
          "multi": false,
          "name": "node",
          "options": [],
          "query": "label_values(node_load1, instance)",
          "refresh": 1,
          "regex": "/\\d+.9100/",
          "skipUrlSync": false,
          "sort": 1,
          "tagValuesQuery": "",
          "tags": [],
          "tagsQuery": "",
          "type": "query",
          "useTags": false
        }
      ]
    },
    "time": {
      "from": "now-5m",
      "to": "now"
    },
    "timepicker": {
      "refresh_intervals": [
        "5s",
        "10s",
        "30s",
        "1m",
        "5m",
        "15m",
        "30m",
        "1h",
        "2h",
        "1d"
      ]
    },
    "timezone": "browser",
    "title": "Monitor Hardware Server External Ver2",
    "uid": "PTMDUCCMC",
    "version": 2
  }
When import this config. You will see the figure bellow
 
