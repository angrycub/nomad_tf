#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo chmod +X /ops/shared/scripts/client.sh
sudo bash -c "NOMAD_BINARY=${nomad_binary} CONSUL_BINARY=${consul_binary}  /ops/shared/scripts/client.sh \"aws\" \"${retry_join}\""
