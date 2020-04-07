variable "name" {
  description = "The name or name prefix of the resources created by this Terraform module."
  default     = "hashistack"
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "ami" {
  description = "The AMI ID to be used for instances."
}

variable "key_name" {
  description = "The Name of the AWS EC2 key pair to preload into the instances"
}

variable owner_name {
  description = "The name of a responsible party; saves as a tag when possible."
}

variable owner_email {
  description = "The email address for a responsible party; saves as a tag when possible."
}

variable "instance_type" {
  description = "The AWS instance type to use for both clients and servers."
  default     = "t2.medium"
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
  description = "The cloud auto-join metadata used by Consul to automatically form a cluster."
  default     = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

variable "consul_binary" {
  description = "An optional URL path to a binary that will replace the installed Consul binary."
  default     = "none"
}

variable "vault_binary" {
  description = "An optional URL path to a binary that will replace the installed Vault binary."
  default     = "none"
}

variable "nomad_binary" {
  description = "An optional URL path to a binary that will replace the installed Nomad binary."
  default     = "none"
}
