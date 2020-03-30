#!/bin/bash

set -e

CONFIGDIR=/ops/shared/config

CONSULCONFIGDIR=/etc/consul.d
NOMADCONFIGDIR=/etc/nomad.d
# HADOOP_VERSION=hadoop-2.9.2
# HADOOPCONFIGDIR=/usr/local/$HADOOP_VERSION/etc/hadoop
HOME_DIR=ubuntu

# Wait for network
sleep 15

function getInterfaceAddress() {
  ip -4 address show "${1}" | awk '/inet / { print $2 }' | cut -d/ -f1
}

function getDefaultRouteAddress() {
  # Default route IP address (seems to be a good way to get host ip)
  ip route get 1.1.1.1 | grep -oP 'src \K\S+'
}

IP_ADDRESS = "$(getDefaultRouteAddress)"
DOCKER_BRIDGE_IP_ADDRESS="$(getInterfaceAddress docker0)"
CLOUD=$1
RETRY_JOIN=$2

# Consul
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul_client.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul_client.hcl
sudo cp $CONFIGDIR/consul_client.hcl $CONSULCONFIGDIR/consul.hcl
sudo cp $CONFIGDIR/consul_connect.hcl $CONSULCONFIGDIR
sudo cp $CONFIGDIR/consul_$CLOUD.service /etc/systemd/system/consul.service

## Replace existing Consul binary if remote file exists
if [[ `wget -S --spider $CONSUL_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $CONSUL_BINARY > consul.zip
  sudo unzip -o consul.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/consul
  sudo chown root:root /usr/local/bin/consul
fi

sudo systemctl start consul.service
sleep 10

# Nomad

## Replace existing Nomad binary if remote file exists
if [[ `wget -S --spider $NOMAD_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $NOMAD_BINARY > nomad.zip
  sudo unzip -o nomad.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/nomad
  sudo chown root:root /usr/local/bin/nomad
fi

sudo cp $CONFIGDIR/nomad_client.hcl $NOMADCONFIGDIR/nomad.hcl
sudo cp $CONFIGDIR/nomad.service /etc/systemd/system/nomad.service

sudo systemctl start nomad.service
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
sudo mv /etc/resolv.conf.new /etc/resolv.conf

# # Hadoop config file to enable HDFS CLI
# sudo cp $CONFIGDIR/core-site.xml $HADOOPCONFIGDIR

# # Move examples directory to $HOME
# sudo mv /ops/examples /home/$HOME_DIR
# sudo chown -R $HOME_DIR:$HOME_DIR /home/$HOME_DIR/examples
# sudo chmod -R 775 /home/$HOME_DIR/examples

# # Update PATH
# echo "export PATH=$PATH:/usr/local/bin/spark/bin:/usr/local/$HADOOP_VERSION/bin" | sudo tee --append /home/$HOME_DIR/.bashrc


# Set env vars for tool CLIs
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre"  | sudo tee --append /home/$HOME_DIR/.bashrc
