variable "name" {
}

variable "region" {
}

variable "ami" {
}

variable "server_instance_type" {
}

variable "client_instance_type" {
}

variable "key_name" {
}

variable "server_count" {
}

variable "client_count" {
}

variable "retry_join" {
}

variable "nomad_binary" {
}

variable "vault_binary" {
}

variable "consul_binary" {
}

variable "owner_name" {
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > private.key"
  }

  provisioner "local-exec" {
    command = "chmod 600 private.key"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "vault-kms-unseal-${var.key_name}"
  public_key = tls_private_key.main.public_key_openssh
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal-${var.key_name}"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "primary" {
  name   = var.name
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = var.name
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data_server" {
  template = file("${path.root}/user-data-server.sh")

  vars = {
    server_count  = var.server_count
    region        = var.region
    retry_join    = var.retry_join
    consul_binary = var.consul_binary
    vault_binary  = var.vault_binary
    nomad_binary  = var.nomad_binary
    kms_key       = aws_kms_key.vault.id
  }
}

data "template_file" "user_data_client" {
  template = file("${path.root}/user-data-client.sh")

  vars = {
    region        = var.region
    retry_join    = var.retry_join
    consul_binary = var.consul_binary
    nomad_binary  = var.nomad_binary
  }
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = "vault-kms-unseal-${var.key_name}"
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.server_count

  #Instance tags
  tags = {
    Name           = "${var.name}-server-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    Owner          = "${var.owner_name}"
    Keep           = ""
  }

  root_block_device {
    volume_size = "50"
  }

  user_data            = data.template_file.user_data_server.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
}

resource "aws_instance" "client" {
  ami                    = var.ami
  instance_type          = var.client_instance_type
  key_name               = "vault-kms-unseal-${var.key_name}"
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count
  depends_on             = [aws_instance.server]

  #Instance tags
  tags = {
    Name           = "${var.name}-client-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    Owner          = "${var.owner_name}"
    Keep           = ""
  }

  root_block_device {
    volume_size = "50"
  }

  user_data            = data.template_file.user_data_client.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.name
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_role_policy" "vault-kms-unseal" {
  name   = "Vault-KMS-Unseal-${var.name}"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.vault-kms-unseal.json
}

output "server_tag_name" {
  value = [aws_instance.server.*.tags.Name]
}

output "client_tag_name" {
  value = [aws_instance.client.*.tags.Name]
}

output "server_public_ips" {
  value = [aws_instance.server.*.public_ip]
}

output "client_public_ips" {
  value = [aws_instance.client.*.public_ip]
}

output "server_private_ips" {
  value = [aws_instance.server.*.private_ip]
}

output "client_private_ips" {
  value = [aws_instance.client.*.private_ip]
}

output "client_addresses" {
  value = join(
    "\n",
    formatlist(
      " * instance %v - Public: %v, Private: %v",
      aws_instance.client.*.tags.Name,
      aws_instance.client.*.public_ip,
      aws_instance.client.*.private_ip,
    ),
  )
}

output "server_addresses" {
  value = join(
    "\n",
    formatlist(
      " * instance %v - Public: %v, Private: %v",
      aws_instance.server.*.tags.Name,
      aws_instance.server.*.public_ip,
      aws_instance.server.*.private_ip,
    ),
  )
}

output "hosts_file" {
  value = join(
    "\n",
    concat(
      formatlist(
        " %v.hs         %v",
        aws_instance.server.*.tags.Name,
        aws_instance.server.*.public_ip,
      ),
      formatlist(
        " %v.hs         %v",
        aws_instance.client.*.tags.Name,
        aws_instance.client.*.public_ip,
      ),
    ),
  )
}

output "ssh_file" {
  value = join(
    "\n",
    concat(
      formatlist(
        "Host %v.hs\n  User ubuntu\n  HostName %v\n",
        aws_instance.server.*.tags.Name,
        aws_instance.server.*.public_dns,
      ),
      formatlist(
        "Host %v.hs\n  User ubuntu\n  HostName %v\n",
        aws_instance.client.*.tags.Name,
        aws_instance.client.*.public_dns,
      ),
    ),
  )
}

