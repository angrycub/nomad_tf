job "jenkins" {
  update {
    min_healthy_time = "30s"
    healthy_deadline = "2m"
    auto_revert = true
  }
  datacenters = ["dc1"]

  type = "service"

  group "cicd" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"

      delay = "25s"

      mode = "delay"
    }

    ephemeral_disk {
      size = 500
    }

    task "jenkins" {
      driver = "docker"

      config {
        image = "lucasdls/jenkins-master:latest"
        port_map {
          http = 8080,
          slave = 50000
        }
      }

      resources {
        cpu    = 1024 # 500 MHz
        memory = 2048 # 256MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "jenkins-server"
        tags = ["global", "cicd",  "urlprefix-/"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
