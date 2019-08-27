job cpu_stress {
  datacenters = ["dc1"]
  type = "system"
  group "group" {
    count = 1
    task "cpu.sh" {
      template {
        data = <<EOH
#!/bin/bash
sudo apt install stress
stress --cpu 2 --timeout 120
EOH
        destination = "local/cpu.sh"
      }

      driver = "exec"
      config { command = "${NOMAD_TASK_DIR}/cpu.sh" }
      resources { memory = 100 cpu = 100 }
    }
  }
}