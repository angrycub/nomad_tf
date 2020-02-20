provider "aws" {
  region  = var.region
  profile = var.profile
}

module "hashistack" {
  source = "../../modules/hashistack"

  name                 = var.name
  region               = var.region
  ami                  = var.ami
  server_instance_type = var.server_instance_type
  client_instance_type = var.client_instance_type
  key_name             = var.key_name
  server_count         = var.server_count
  client_count         = var.client_count
  retry_join           = var.retry_join
  consul_binary        = var.consul_binary
  vault_binary         = var.vault_binary
  nomad_binary         = var.nomad_binary
  owner_name           = var.owner_name
}

