provider "aws" {
  region = var.region
}

module "hashistack" {
  source = "../../modules/hashistack"

  name                 = var.name
  owner_name           = var.owner_name
  owner_email          = var.owner_email
  region               = var.region
  ami                  = var.ami
  key_name             = var.key_name
  server_instance_type = var.server_instance_type
  server_count         = var.server_count
  client_instance_type = var.server_instance_type
  client_count         = var.client_count
  retry_join           = var.retry_join
  consul_binary        = var.consul_binary
  vault_binary         = var.vault_binary
  nomad_binary         = var.nomad_binary
  whitelist_ip         = var.whitelist_ip
}
