#!/bin/bash

apt update 
apt upgrade
apt install unzip wget

wget https://github.com/prometheus/prometheus/releases/download/v2.21.0/prometheus-2.21.0.linux-amd64.tar.gz

