variable "name" {}
variable "owner_name" {}
variable "owner_email" {}
variable "region" {}
variable "ami" {}
variable "key_name" {}
variable "server_instance_type" {}
variable "server_count" {}
variable "client_instance_type" {}
variable "client_count" {}
variable "root_block_device_size" {}
variable "retry_join" {}
variable "nomad_binary" {}
variable "vault_binary" {}
variable "consul_binary" {}
variable "whitelist_ip" {}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "server_lb" {
  name   = "${var.name}-server-lb"
  vpc_id = data.aws_vpc.default.id

  # Nomad
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "primary" {
  name   = var.name
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Nomad
  ingress {
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    cidr_blocks     = [var.whitelist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }

  # Fabio 
  ingress {
    from_port   = 9998
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = [var.whitelist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }

  # HDFS NameNode UI
  ingress {
    from_port   = 50070
    to_port     = 50070
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # HDFS DataNode UI
  ingress {
    from_port   = 50075
    to_port     = 50075
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Spark history server UI
  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Jupyter
  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
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
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.server_count

  #Instance tags
  tags = {
    Name           = "${var.name}-server-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    OwnerName      = var.owner_name
    OwnerEmail     = var.owner_email
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_server.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
}

resource "aws_instance" "client" {
  ami                    = var.ami
  instance_type          = var.client_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count
  depends_on             = [aws_instance.server]

  #Instance tags
  tags = {
    Name           = "${var.name}-client-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    OwnerName      = var.owner_name
    OwnerEmail     = var.owner_email
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
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

resource "aws_elb" "server_lb" {
  name               = "${var.name}-server-lb"
  availability_zones = distinct(aws_instance.server.*.availability_zone)
  internal           = false
  instances          = aws_instance.server.*.id
  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port           = 4646
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }
  security_groups = [aws_security_group.server_lb.id]
}

output "server_tag_name" {
  value = aws_instance.server.*.tags.Name
}

output "client_tag_name" {
  value = aws_instance.client.*.tags.Name
}

output "server_public_ips" {
  value = aws_instance.server.*.public_ip
}

output "client_public_ips" {
  value = aws_instance.client.*.public_ip
}

output "server_private_ips" {
  value = aws_instance.server.*.private_ip
}

output "client_private_ips" {
  value = aws_instance.client.*.private_ip
}

output "client_addresses" {
  value = join("\n", formatlist(" * instance %v - Public: %v, Private: %v", aws_instance.client.*.tags.Name, aws_instance.client.*.public_ip, aws_instance.client.*.private_ip))
}
output "server_addresses" {
  value = join("\n", formatlist(" * instance %v - Public: %v, Private: %v", aws_instance.server.*.tags.Name, aws_instance.server.*.public_ip, aws_instance.server.*.private_ip))
}

output "elb_dns" {
  value = aws_elb.server_lb.dns_name
}

output "nomad_addr" {
  value = "http://${aws_elb.server_lb.dns_name}:4646"
}

output "consul_addr" {
  value = "http://${aws_elb.server_lb.dns_name}:8500"
}

output "hosts_file" {
  value = join("\n", concat(
    formatlist(" %-16s  %v.hs", aws_instance.server.*.public_ip, aws_instance.server.*.tags.Name),
    formatlist(" %-16v  %v.hs", aws_instance.client.*.public_ip, aws_instance.client.*.tags.Name)
  ))
}

output "ssh_file" {
  value = join("\n", concat(
    formatlist("Host %v.hs\n  User ubuntu\n  HostName %v\n", aws_instance.server.*.tags.Name, aws_instance.server.*.public_dns),
    formatlist("Host %v.hs\n  User ubuntu\n  HostName %v\n", aws_instance.client.*.tags.Name, aws_instance.client.*.public_dns)
  ))
}
