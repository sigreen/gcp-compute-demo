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

# Let's get PostgreSQL up
cat <<-EOF > /docker-compose.yml
version: '3'
services:
  postgres:
    network_mode: "host"
    environment:
      POSTGRES_DB: "products"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "password"
    image: "hashicorpdemoapp/product-api-db:v0.0.11"
EOF

/usr/local/bin/docker-compose up -d

# Get the product API up
mkdir -p /etc/secrets
cat <<-EOF > /etc/secrets/db-creds
{
"db_connection": "host=${local_ipv4} port=5432 user=postgres password=password dbname=products sslmode=disable",
  "bind_address": ":9090",
  "metrics_address": ":9103"
}
EOF

cat <<-EOF > /docker-compose.yml
version: '3'
services:
  product:
    network_mode: "host"
    environment:
      CONFIG_FILE: "/etc/secrets/db-creds"
    image: "hashicorpdemoapp/product-api:v0.0.11"
    volumes:
       - /etc/secrets/db-creds:/etc/secrets/db-creds
EOF

/usr/local/bin/docker-compose up -d

# Get the public API up
cat <<-EOF > /docker-compose.yml
version: '3'
services:
  public:
    network_mode: "host"
    environment:
      BIND_ADDRESS: ":8080"
      PRODUCT_API_URI: "http://${local_ipv4}:9090"
    image: "hashicorpdemoapp/public-api:v0.0.1"
EOF

/usr/local/bin/docker-compose up -d

# Setup front-end
mkdir -p /etc/nginx/conf.d

cat <<-EOF > /etc/nginx/conf.d/default.conf
# /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;
    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    # Proxy pass the api location to save CORS
    # Use location exposed by Consul connect
    location /api {
        proxy_pass http://${local_ipv4}:8080;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF

cat <<-EOF > /docker-compose.yml
version: '3'
services:
  frontend:
    container_name: "frontend"
    network_mode: "host"
    image: "hashicorpdemoapp/frontend:v0.0.3"
    volumes:
       - /etc/nginx/conf.d/:/etc/nginx/conf.d/
EOF

/usr/local/bin/docker-compose up -d
