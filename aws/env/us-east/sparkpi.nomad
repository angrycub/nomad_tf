job "sparkpi-launcher" {
  datacenters = ["dc1"]
  type = "batch"
  periodic {
    cron = "*/2 * * * * *"
    prohibit_overlap = true
  }

  group "spark" {
    task "sparkpi" {
      driver = "exec"

      config {
        command = "/usr/local/bin/spark/bin/spark-submit"
        args = [
  "--class", "org.apache.spark.examples.JavaSparkPi",
  "--master", "nomad",
  "--deploy-mode", "cluster",
  "--conf", "spark.executor.instances=4",
  "--conf", "spark.nomad.cluster.monitorUntil=complete",
  "--conf", "spark.eventLog.enabled=true",
  "--conf", "spark.eventLog.dir=hdfs://hdfs.service.consul/spark-events",
  "--conf", "spark.nomad.sparkDistribution=https://s3.amazonaws.com/nomad-spark/spark-2.1.0-bin-nomad.tgz",
  "https://s3.amazonaws.com/nomad-spark/spark-examples_2.11-2.1.0-SNAPSHOT.jar", "100"
        ]
      }
    }
  }
}
