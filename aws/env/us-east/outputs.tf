output "IP_Addresses" {
  value = <<CONFIGURATION

Server IPs:
${module.hashistack.server_addresses}
Client IPs:
${module.hashistack.client_addresses}


To connect, SSH into any client or server with
`ssh ubuntu@PUBLIC_IP -i private.key`. The private.key is created on any new instance
run and tied to the KMS key for Vault Unseal.You can test the integrity of the cluster
by running:

  $ consul members
  $ nomad server-members
  $ nomad node-status

If you see an error message like the following when running any of the above
commands, it usually indicates that the configuration script has not finished
executing:

"Error querying servers: Get http://127.0.0.1:4646/v1/agent/members: dial tcp
127.0.0.1:4646: getsockopt: connection refused"

Simply wait a few seconds and rerun the command if this occurs.

The Nomad UI can be accessed at http://PUBLIC_IP:4646/ui.
The Consul UI can be accessed at http://PUBLIC_IP:8500/ui.

CONFIGURATION
}
