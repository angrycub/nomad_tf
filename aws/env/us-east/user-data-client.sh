#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash -c "nomad_binary=${nomad_binary} vault_binary=${vault_binary} consul_binary=${consul_binary}  /ops/shared/scripts/client.sh \"aws\" \"${retry_join}\""
