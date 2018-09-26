name          = "cv_nomad"
region        = "us-east-1"
instance_type = "t2.micro"
ami           = "ami-ec237c93"
key_name      = "cv_hc-support-eng"
#key_name ="cv_nomad_vault_repro"
server_count  = "3"
client_count  = "3"

nomad_binary  = "https://releases.hashicorp.com/nomad/0.7.1/nomad_0.7.1_linux_amd64.zip"


