job docker_network {
  datacenters = ["dc1"]
  type = "system"
  group "group" {
    count = 1
    task "network.sh" {
      template {
        data = <<EOH
#!/bin/bash

docker network create --driver bridge jenkins 
EOH
        destination = "local/network.sh"
      }

      driver = "exec"
      config { 
        command = "${NOMAD_TASK_DIR}/network.sh" 
      }
    }
  }
}