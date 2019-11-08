job "structure" {
  meta {
    "spark.nomad.role" = "application"
  }

  # A driver group is only added in cluster mode
  group "driver" {
    task "driver" {
      meta {
        "spark.nomad.role" = "driver"
      }
    service {
        name = "spiderham123"
        tags = ["spidergirl", "spiderboy","queens"]
    }
    }
  }

  group "executors" {
    count = 1
    task "executor" {
      meta {
        "spark.nomad.role" = "executor"
      }
    }
  }
}