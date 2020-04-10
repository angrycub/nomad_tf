variable "created_email" {}
variable "created_name" {}

source "amazon-ebs" "hashistack" {
  ami_name = "Hashistack {{timestamp}}"
  region = "us-east-1"
  instance_type = "t2.medium"

  #source_ami = "ami-0a4f4704a9146742a"
  source_ami_filter {
      filters {
        virtualization-type = "hvm"
        name =  "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
        root-device-type = "ebs"
      }
      owners = ["099720109477"]  # Canonical's owner ID
      most_recent = true
  }

  communicator = "ssh"
  ssh_username = "ubuntu"

  ami_groups = ["all"]

  tags {
    OS_Version = "Ubuntu"
    Release = "18.04"
    Architecture = "amd64"
    Created_Email = var.created_email
    Created_Name = var.created_name
  }
}

build {
  sources = [
    "source.amazon-ebs.hashistack"
  ]

  provisioner "shell" {
    inline = [
      "sudo mkdir /ops",
      "sudo chmod 777 /ops"
    ]
  }

  provisioner "file" {
    source = "../shared"
    destination = "/ops"
  }

  provisioner "shell" {
    script = "../shared/scripts/setup.sh"
  }
}



