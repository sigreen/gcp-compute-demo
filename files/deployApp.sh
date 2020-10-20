#!/bin/bash

# Let's get Consul up and running
#
# Consul install
apt install unzip

curl -O https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip

unzip ./consul_1.8.4_linux_amd64.zip

cp ./consul /usr/local/bin

# Consul configure and bring alive
local_ipv4=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)

mkdir -p /consul/data /etc/consul.d

cat <<-EOF > /etc/consul.d/server.json
{
  "datacenter": "dc1",
  "bind_addr": "${local_ipv4}",
  "client_addr": "0.0.0.0",
  "data_dir": "/consul/data",
  "log_level": "INFO",
  "node_name": "ConsulServer",
  "server": true,
  "ui": true,
  "bootstrap_expect": 1,
  "leave_on_terminate": false,
  "skip_leave_on_interrupt": true,
  "rejoin_after_leave": true
}
EOF

consul agent -dev -config-file=/etc/consul.d/server.json > ./consul.log 2>&1 &



mkdir -p /vault/data 
