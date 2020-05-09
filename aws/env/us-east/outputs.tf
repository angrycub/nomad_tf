output "ssh_file" {
  sensitive = true
  value     = module.hashistack.ssh_file
}

output "hosts_file" {
  value = module.hashistack.hosts_file
}

output "elb_dns" {
  value = module.hashistack.elb_dns
}

output "nomad_addr" {
  value = module.hashistack.nomad_addr
}

output "consul_addr" {
  value = module.hashistack.consul_addr
}

output "IP_Addresses" {
  value = <<CONFIGURATION

Server IPs:
${module.hashistack.server_addresses}
Client IPs:
${module.hashistack.client_addresses}


To connect, add your private key and SSH into any client or server with
`ssh ubuntu@PUBLIC_IP`. You can test the integrity of the cluster by running:

  $ consul members
  $ nomad server-members
  $ nomad node-status

If you see an error message like the following when running any of the above
commands, it usually indicates that the configuration script has not finished
executing:

"Error querying servers: Get http://127.0.0.1:4646/v1/agent/members: dial tcp
127.0.0.1:4646: getsockopt: connection refused"

Simply wait a few seconds and rerun the command if this occurs.

The Nomad UI can be accessed at ${module.hashistack.nomad_addr}/ui .
The Consul UI can be accessed at ${module.hashistack.consul_addr}/ui .

CONFIGURATION
}
