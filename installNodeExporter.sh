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
