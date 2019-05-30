# Provision a Nomad cluster with Vault Auto Unsealed Via KMS on AWS

## Pre-requisites

To get started, create the following:

- AWS account
- [API access keys](http://aws.amazon.com/developers/access-keys/)
- [SSH key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

## Set the AWS environment variables

```bash
$ export AWS_ACCESS_KEY_ID=[AWS_ACCESS_KEY_ID]
$ export AWS_SECRET_ACCESS_KEY=[AWS_SECRET_ACCESS_KEY]
```

## Build an AWS machine image with Packer

[Packer](https://www.packer.io/intro/index.html) is HashiCorp's open source tool
for creating identical machine images for multiple platforms from a single
source configuration. The Terraform templates included in this repo reference a
publicly available Amazon machine image (AMI) by default. The AMI can be customized
through modifications to the [build configuration script](../shared/scripts/setup.sh)
and [packer.json](packer.json).

Use the following command to build the AMI:

```bash
$ packer build packer.json
```

## Provision a cluster with Terraform

`cd` to an environment subdirectory:

```bash
$ cd env/us-east
```

Update `terraform.tfvars` with your SSH key name and your AMI ID if you created
a custom AMI:

```bash
region                  = "us-east-1"
ami                     = "ami-0ab81575"
instance_type           = "t2.medium"
key_name                = "KEY_NAME"
server_count            = "3"
client_count            = "4"
```

Modify the `region`, `instance_type`, `server_count`, and `client_count` variables
as appropriate. At least one client and one server are required. You can
optionally replace the Nomad binary at runtime by adding the `nomad_binary`
variable like so:

```bash
region                  = "us-east-1"
ami                     = "ami-0ab81575"
instance_type           = "t2.medium"
key_name                = "KEY_NAME"
server_count            = "3"
client_count            = "4"
nomad_binary            = "https://releases.hashicorp.com/nomad/0.7.0/nomad_0.7.0_linux_amd64.zip"
```

Provision the cluster:

```bash
$ terraform init
$ terraform get
$ terraform plan
$ terraform apply
```

## Access the cluster

SSH to one of the servers using its public IP:

```bash
$ ssh -i private.key ubuntu@PUBLIC_IP
```

The infrastructure that is provisioned for this test environment is configured to
allow all traffic over port 22. This is obviously not recommended for production
deployments.

## Working With Vault

```bash
# Once inside the EC2 instance...
$ vault status

# Initialize Vault
$ vault operator init -key-shares=1 -key-threshold=1

# Restart the Vault server
$ sudo systemctl restart vault

# Check to verify that the Vault is auto-unsealed
$ vault status

$ vault login <INITIAL_ROOT_TOKEN>

# Cleaning up local terraform deployment directory
$ terraform destroy -force
$ rm -rf .terraform terraform.tfstate* private.key
```
## Next Steps

Click [here](../README.md#test) for next steps.
