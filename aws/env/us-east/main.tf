variable "name" {
  description = "Used to name various infrastructure components"
  default     = "hashistack"
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "ami" {
}

variable "instance_type" {
  description = "The AWS instance type to use for both clients and servers."
  default     = "t2.medium"
}

variable "key_name" {
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "client_count" {
  description = "The number of clients to provision."
  default     = "4"
}

variable "retry_join" {
  description = "Used by Consul to automatically form a cluster."
  default     = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

variable "consul_binary" {
  description = "Used to replace the machine image installed Consul binary."
  default     = "none"
}

variable "vault_binary" {
  description = "Used to replace the machine image installed Vault binary."
  default     = "none"
}

variable "nomad_binary" {
  description = "Used to replace the machine image installed Nomad binary."
  default     = "none"
}

provider "aws" {
  region = var.region
}

module "hashistack" {
  source = "../../modules/hashistack"

  name          = var.name
  region        = var.region
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  server_count  = var.server_count
  client_count  = var.client_count
  retry_join    = var.retry_join
  consul_binary = var.consul_binary
  vault_binary  = var.vault_binary
  nomad_binary  = var.nomad_binary
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

The Nomad UI can be accessed at http://PUBLIC_IP:4646/ui.
The Consul UI can be accessed at http://PUBLIC_IP:8500/ui.

CONFIGURATION

}

