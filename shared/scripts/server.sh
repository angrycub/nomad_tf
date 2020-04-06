#!/bin/bash
SHAREDDIR=/ops/shared
CONFIGDIR=$SHAREDDIR/config
SCRIPTDIR=$SHAREDDIR/scripts

source $SCRIPTDIR/net.sh
set -e

CONSULCONFIGDIR=/etc/consul.d
VAULTCONFIGDIR=/etc/vault.d
NOMADCONFIGDIR=/etc/nomad.d
HOME_DIR=ubuntu

# Wait for network
sleep 15

IP_ADDRESS=$(net_getDefaultRouteAddress)
DOCKER_BRIDGE_IP_ADDRESS=$(net_getInterfaceAddress docker0)
CLOUD=$1
SERVER_COUNT=$2
RETRY_JOIN=$3

# Consul
## Replace existing Consul binary if remote file exists
if [[ `wget -S --spider $CONSUL_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $CONSUL_BINARY > consul.zip
  sudo unzip -o consul.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/consul
  sudo chown root:root /usr/local/bin/consul
fi

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul.hcl
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/consul.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul.hcl
sudo cp $CONFIGDIR/consul.hcl $CONSULCONFIGDIR
sudo cp $CONFIGDIR/consul_connect.hcl $CONSULCONFIGDIR
sudo cp $CONFIGDIR/consul_$CLOUD.service /etc/systemd/system/consul.service

sudo systemctl start consul.service
sleep 10
export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500
export CONSUL_RPC_ADDR=$IP_ADDRESS:8400

# Vault
## Replace existing Vault binary if remote file exists
if [[ `wget -S --spider $VAULT_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $VAULT_BINARY > vault.zip
  sudo unzip -o vault.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/vault
  sudo chown root:root /usr/local/bin/vault
fi

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/vault.hcl
sudo cp $CONFIGDIR/vault.hcl $VAULTCONFIGDIR
sudo cp $CONFIGDIR/vault.service /etc/systemd/system/vault.service

sudo systemctl start vault.service

# Nomad

## Replace existing Nomad binary if remote file exists
if [[ `wget -S --spider $NOMAD_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $NOMAD_BINARY > nomad.zip
  sudo unzip -o nomad.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/nomad
  sudo chown root:root /usr/local/bin/nomad
fi

sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/nomad.hcl
sudo cp $CONFIGDIR/nomad.hcl $NOMADCONFIGDIR
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

# Set env vars for tool CLIs
echo "export CONSUL_RPC_ADDR=$IP_ADDRESS:8400" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre"  | sudo tee --append /home/$HOME_DIR/.bashrc

