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

# HADOOPVERSION=2.9.2
# HADOOPDOWNLOAD=http://apache.mirror.iphh.net/hadoop/common/hadoop-${HADOOPVERSION}/hadoop-${HADOOPVERSION}.tar.gz

# NOMADSPARKDOWNLOAD=https://github.com/hashicorp/nomad-spark/releases/download/v2.2.0-nomad-0.7.0-20180618/spark-2.2.0-bin-nomad-0.7.0-20180618.tgz
# NOMADSPARKTARBALL=spark-2.2.0-bin-nomad-0.7.0-20180618.tgz
# NOMADSPARKDIR=$(basename ${NOMADSPARKTARBALL} .tgz)

# Dependencies
sudo apt-get update
sudo apt-get install -y software-properties-common unzip tree redis-tools jq curl tmux

# Disable the firewall

sudo ufw disable || echo "ufw not installed"

# Consul

curl -L ${CONSULDOWNLOAD}> consul.zip

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

curl -L ${VAULTDOWNLOAD}> vault.zip

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

curl -L ${NOMADDOWNLOAD}> nomad.zip

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

# # Spark
# sudo wget -P /ops/examples/spark ${NOMADSPARKDOWNLOAD}
# sudo tar -xvf /ops/examples/spark/${NOMADSPARKTARBALL} --directory /ops/examples/spark
# sudo mv /ops/examples/spark/${NOMADSPARKDIR} /usr/local/bin/spark
# sudo chown -R root:root /usr/local/bin/spark

# # Hadoop (to enable the HDFS CLI)
# wget -O - ${HADOOPDOWNLOAD} | sudo tar xz -C /usr/local/
