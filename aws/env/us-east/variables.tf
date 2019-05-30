variable "name" {
  description = "Used to name various infrastructure components"
  default     = "hashistack"
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

## Adding support for those using ~/.aws/credentials with multiple profiles
variable "profile" {
  description = "The profile to use"
  default     = "default"
}

variable "ami" {}

variable "instance_type" {
  description = "The AWS instance type to use for both clients and servers."
  default     = "t2.medium"
}

variable "key_name" {}

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
