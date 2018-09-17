name          = "cv_nomad"
region        = "us-east-1"
instance_type = "t2.micro"
ami           = "ami-ec237c93"
key_name      = "cv_hc-support-eng"
server_count  = "3"
client_count  = "3"

nomad_binary  = "https://angrycub-hc.s3.amazonaws.com/public/nomad-enterprise_0.8.5-dev%2Bent_linux_amd64.zip"


