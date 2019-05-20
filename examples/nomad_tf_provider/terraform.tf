# Configure the Nomad provider
provider "nomad" {
  address = "http://localhost:4646"
}

data "template_file" "job" {
  template = "${file("jenkins.hcl.tmpl")}"
}

data "template_file" "job2" {
  template = "${file("fabio.hcl.tmpl")}"
}

# Register a job
resource "nomad_job" "fabio" {
  jobspec = "${data.template_file.job2.rendered}"
}

# Creates delay between starting fabio and jenkins
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "fabio" = "${nomad_job.fabio.id}"
  }
}

# Register a job
resource "nomad_job" "jenkins" {
  jobspec = "${data.template_file.job.rendered}"
  depends_on = ["null_resource.delay"]
}
