#!/bin/bash

set -e

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

cd /ops

CONFIGDIR=/ops/shared/config

CONSULVERSION=1.5.0
CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSULVERSION}/consul_${CONSULVERSION}_linux_amd64.zip
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

VAULTVERSION=1.1.2
VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULTVERSION}/vault_${VAULTVERSION}_linux_amd64.zip
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

NOMADVERSION=0.9.2
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/nomad_${NOMADVERSION}_linux_amd64.zip
NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

TERRAFORMVERSION=0.11.14
TERRAFORMDOWNLOAD=https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip

HADOOPVERSION=2.7.3
HADOOPCONFIGDIR=/usr/local/hadoop-$HADOOPVERSION/etc/hadoop
#HADOOPDOWNLOAD=http://apache.mirror.iphh.net/hadoop/common/hadoop-${HADOOPVERSION}/hadoop-${HADOOPVERSION}.tar.gz

# use S3 local cache of hadoop
#HADOOPDOWNLOAD=https://angrycub-hc.s3.amazonaws.com/public/hadoop-3.2.0.tar.gz
HADOOPDOWNLOAD=http://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

NOMADSPARKDOWNLOAD=https://github.com/hashicorp/nomad-spark/releases/download/v2.4.0-nomad-0.8.6-20181220/spark-2.4.0-bin-nomad-0.8.6-20181220.tgz
NOMADSPARKTARBALL=spark-2.4.0-bin-nomad-0.8.6-20181220.tgz
NOMADSPARKDIR=$(basename ${NOMADSPARKTARBALL} .tgz)

HOME_DIR=ubuntu

# Dependencies
sudo apt-get update -y
sudo apt-get install -y software-properties-common unzip tree redis-tools jq curl tmux

# Numpy (for Spark)
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python-setuptools python3-pip
sudo -H pip3 install numpy

# Ansible
sudo apt-get install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Disable the firewall

sudo ufw disable || echo "ufw not installed"

# Remove ResovlerStub
if [ -f "/etc/systemd/resolved.conf" ]; then
  echo "Disabling the DNSStubListener"
  echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
fi

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

# Terraform

curl -L ${TERRAFORMDOWNLOAD}> terraform.zip

## Install
sudo unzip terraform.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/terraform
sudo chown root:root /usr/local/bin/terraform

# Docker
distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
sudo apt-get install -y apt-transport-https ca-certificates gnupg2
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${distro} $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}


# rkt
VERSION=1.23.0
DOWNLOAD=https://github.com/rkt/rkt/releases/download/v${VERSION}/rkt-v${VERSION}.tar.gz

function install_rkt() {
	wget -q -O /tmp/rkt.tar.gz "${DOWNLOAD}"
	tar -C /tmp -xvf /tmp/rkt.tar.gz
	sudo mv /tmp/rkt-v${VERSION}/rkt /usr/local/bin
	sudo mv /tmp/rkt-v${VERSION}/*.aci /usr/local/bin
}

function configure_rkt_networking() {
	sudo mkdir -p /etc/rkt/net.d
    sudo bash -c 'cat << EOT > /etc/rkt/net.d/99-network.conf
{
  "name": "default",
  "type": "ptp",
  "ipMasq": false,
  "ipam": {
    "type": "host-local",
    "subnet": "172.16.28.0/24",
    "routes": [
      {
        "dst": "0.0.0.0/0"
      }
    ]
  }
}
EOT'
}

install_rkt
configure_rkt_networking

# Java
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre"  | sudo tee --append /home/$HOME_DIR/.bashrc


# Spark
sudo wget -P /ops/examples/spark ${NOMADSPARKDOWNLOAD}
sudo tar -xvf /ops/examples/spark/${NOMADSPARKTARBALL} --directory /ops/examples/spark
sudo mv /ops/examples/spark/${NOMADSPARKDIR} /usr/local/bin/spark
sudo chown -R root:root /usr/local/bin/spark

# Hadoop (to enable the HDFS CLI)
wget -O - ${HADOOPDOWNLOAD} | sudo tar xz -C /usr/local/
sudo cp $CONFIGDIR/core-site.xml $HADOOPCONFIGDIR

# Move examples directory to $HOME
sudo mv /ops/examples /home/$HOME_DIR
sudo chown -R $HOME_DIR:$HOME_DIR /home/$HOME_DIR/examples
sudo chmod -R 775 /home/$HOME_DIR/examples

# Update PATH
echo "export PATH=$PATH:/usr/local/bin/spark/bin:/usr/local/hadoop-$HADOOPVERSION/bin" | sudo tee --append /home/$HOME_DIR/.bashrc

# Keep AMI up to Update
sudo apt-get upgrade -y
