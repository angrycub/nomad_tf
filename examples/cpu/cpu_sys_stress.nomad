job cpu_sys_nomad {
  datacenters = ["dc1"]
  type = "system"
  group "group" {
    count = 1
    task "cpu.sh" {
      template {
        data = <<EOH
#!/bin/bash

stress --io 4 --hdd 4 --timeout 120
EOH
        destination = "local/cpu.sh"
      }

      driver = "exec"
      config { command = "${NOMAD_TASK_DIR}/cpu.sh" }
      resources { memory = 100 cpu = 100 }
    }
  }
}