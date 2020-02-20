#!/bin/bash

set -e

NOMADVERSION=0.8.7
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/nomad_${NOMADVERSION}_linux_amd64.zip

# Nomad
sudo systemctl stop nomad

curl -L ${NOMADDOWNLOAD}> nomad.zip

## Install
sudo unzip nomad.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

sudo systemctl start nomad

#Cleanup
rm -rf nomad.zip