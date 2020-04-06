#!/bin/bash

set -e

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

cd /ops

CONFIGDIR=/ops/shared/config

CONSULVERSION=1.7.0
CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSULVERSION}/consul_${CONSULVERSION}_linux_amd64.zip
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

VAULTVERSION=1.3.4
VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULTVERSION}/vault_${VAULTVERSION}_linux_amd64.zip
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

NOMADVERSION=0.10.4
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/nomad_${NOMADVERSION}_linux_amd64.zip
NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

CNIVERSION=0.8.4
CNIDOWNLOAD=https://github.com/containernetworking/plugins/releases/download/v${CNIVERSION}/cni-plugins-linux-amd64-v${CNIVERSION}.tgz
CNIDIR=/opt/cni

# Dependencies
sudo apt-get update
sudo apt-get install -y software-properties-common unzip tree redis-tools jq curl tmux dnsmasq

# Disable the firewall
sudo ufw disable || echo "ufw not installed"

# Consul
curl -L -o consul.zip ${CONSULDOWNLOAD}

## Install
sudo unzip consul.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

## Configure
sudo mkdir -p ${CONSULCONFIGDIR}
sudo chmod 755 ${CONSULCONFIGDIR}
sudo mkdir -p ${CONSULDIR}
sudo chmod 755 ${CONSULDIR}

# Vault
curl -L -o vault.zip ${VAULTDOWNLOAD}

## Install
sudo unzip vault.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

## Configure
sudo mkdir -p ${VAULTCONFIGDIR}
sudo chmod 755 ${VAULTCONFIGDIR}
sudo mkdir -p ${VAULTDIR}
sudo chmod 755 ${VAULTDIR}

# Nomad
curl -L -o nomad.zip ${NOMADDOWNLOAD}

## Install
sudo unzip nomad.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

## Configure
sudo mkdir -p ${NOMADCONFIGDIR}
sudo chmod 755 ${NOMADCONFIGDIR}
sudo mkdir -p ${NOMADDIR}
sudo chmod 755 ${NOMADDIR}

# Docker
distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
sudo apt-get install -y apt-transport-https ca-certificates gnupg2 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${distro} $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Java
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update 
sudo apt-get install -y openjdk-8-jdk
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# CNI plugins
curl -L -o cni-plugins.tgz ${CNIDOWNLOAD}
sudo mkdir -p ${CNIDIR}/bin
sudo tar -C ${CNIDIR}/bin -xzf cni-plugins.tgz

# dnsmasq config
sudo cp /ops/shared/config/10-consul.dnsmasq /etc/dnsmasq.d/10-consul

