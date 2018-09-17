## Spark Issue @ Jet.com

**template.json**

```
{
  "Job": {
        "Periodic": {
            "Enabled": true,
            "ProhibitOverlap": true,
            "Spec": "*/2 * * * * *",
            "SpecType": "cron",
            "TimeZone": "UTC"
        }
  }
}
```

**command**

```
spark-submit \
>   --class org.apache.spark.examples.JavaSparkPi \
>   --master nomad \
>   --deploy-mode cluster \
>   --conf spark.executor.instances=4 \
>   --conf spark.nomad.sparkDistribution=https://s3.amazonaws.com/nomad-spark/spark-2.1.0-bin-nomad.tgz \
>   --conf spark.nomad.job.template=template.json \
>   https://s3.amazonaws.com/nomad-spark/spark-examples_2.11-2.1.0-SNAPSHOT.jar 100
```

**output**

```
ubuntu@ip-172-31-52-178:~/examples/spark$ spark-submit \
>   --class org.apache.spark.examples.JavaSparkPi \
>   --master nomad \
>   --deploy-mode cluster \
>   --conf spark.executor.instances=4 \
>   --conf spark.nomad.sparkDistribution=https://s3.amazonaws.com/nomad-spark/spark-2.1.0-bin-nomad.tgz \
>   --conf spark.nomad.job.template=template.json \
>   https://s3.amazonaws.com/nomad-spark/spark-examples_2.11-2.1.0-SNAPSHOT.jar 100
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
18/06/07 01:28:14 INFO NomadClusterModeLauncher: Running org.apache.spark.deploy.nomad.NomadClusterModeLauncher
18/06/07 01:28:14 INFO SparkNomadJob: Creating job from provided template
18/06/07 01:28:14 INFO SparkNomadJob: Will run as Nomad job [org.apache.spark.examples.JavaSparkPi-2018-06-07T01:28:14.510Z] with priority 40 in datacenter(s) [dc1]
18/06/07 01:28:14 WARN Utils: Your hostname, ip-172-31-52-178 resolves to a loopback address: 127.0.0.1; using 172.31.52.178 instead (on interface eth0)
18/06/07 01:28:14 WARN Utils: Set SPARK_LOCAL_IP if you need to bind to another address
18/06/07 01:28:14 INFO NomadClusterModeLauncher: Will access Nomad API at http://172.31.52.178:4646
18/06/07 01:28:14 INFO SparkNomadJobController: Starting driver in Nomad job org.apache.spark.examples.JavaSparkPi-2018-06-07T01:28:14.510Z
18/06/07 01:28:15 ERROR NomadClusterModeLauncher: Driver failure
com.hashicorp.nomad.javasdk.ErrorResponseException: GET http://172.31.52.178:4646/v1/evaluation/ resulted in error response status HTTP/1.1 500 Internal Server Error: eval lookup failed: index error: UUID must be 36 characters
	at com.hashicorp.nomad.javasdk.ErrorResponseException.signaledInStatus(ErrorResponseException.java:47)
	at com.hashicorp.nomad.javasdk.NomadApiClient.execute(NomadApiClient.java:332)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQueryRaw(ApiBase.java:221)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQuery(ApiBase.java:116)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQuery(ApiBase.java:101)
	at com.hashicorp.nomad.javasdk.EvaluationsApi.info(EvaluationsApi.java:56)
	at com.hashicorp.nomad.javasdk.EvaluationsApi.pollForCompletion(EvaluationsApi.java:163)
	at com.hashicorp.nomad.scalasdk.ScalaEvaluationsApi.pollForCompletion(ScalaEvaluationsApi.scala:58)
	at com.hashicorp.nomad.scalasdk.ScalaEvaluationsApi.pollForCompletion(ScalaEvaluationsApi.scala:66)
	at org.apache.spark.scheduler.cluster.nomad.NomadJobManipulator.register(NomadJobManipulator.scala:79)
	at org.apache.spark.scheduler.cluster.nomad.NomadJobManipulator.create(NomadJobManipulator.scala:38)
	at org.apache.spark.scheduler.cluster.nomad.SparkNomadJobController.startDriver(SparkNomadJobController.scala:40)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher.submit(NomadClusterModeLauncher.scala:62)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher$.main(NomadClusterModeLauncher.scala:215)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher.main(NomadClusterModeLauncher.scala)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.apache.spark.deploy.SparkSubmit$.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:804)
	at org.apache.spark.deploy.SparkSubmit$.doRunMain$1(SparkSubmit.scala:181)
	at org.apache.spark.deploy.SparkSubmit$.submit(SparkSubmit.scala:206)
	at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:120)
	at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
Exception in thread "main" com.hashicorp.nomad.javasdk.ErrorResponseException: GET http://172.31.52.178:4646/v1/evaluation/ resulted in error response status HTTP/1.1 500 Internal Server Error: eval lookup failed: index error: UUID must be 36 characters
	at com.hashicorp.nomad.javasdk.ErrorResponseException.signaledInStatus(ErrorResponseException.java:47)
	at com.hashicorp.nomad.javasdk.NomadApiClient.execute(NomadApiClient.java:332)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQueryRaw(ApiBase.java:221)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQuery(ApiBase.java:116)
	at com.hashicorp.nomad.javasdk.ApiBase.executeServerQuery(ApiBase.java:101)
	at com.hashicorp.nomad.javasdk.EvaluationsApi.info(EvaluationsApi.java:56)
	at com.hashicorp.nomad.javasdk.EvaluationsApi.pollForCompletion(EvaluationsApi.java:163)
	at com.hashicorp.nomad.scalasdk.ScalaEvaluationsApi.pollForCompletion(ScalaEvaluationsApi.scala:58)
	at com.hashicorp.nomad.scalasdk.ScalaEvaluationsApi.pollForCompletion(ScalaEvaluationsApi.scala:66)
	at org.apache.spark.scheduler.cluster.nomad.NomadJobManipulator.register(NomadJobManipulator.scala:79)
	at org.apache.spark.scheduler.cluster.nomad.NomadJobManipulator.create(NomadJobManipulator.scala:38)
	at org.apache.spark.scheduler.cluster.nomad.SparkNomadJobController.startDriver(SparkNomadJobController.scala:40)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher.submit(NomadClusterModeLauncher.scala:62)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher$.main(NomadClusterModeLauncher.scala:215)
	at org.apache.spark.deploy.nomad.NomadClusterModeLauncher.main(NomadClusterModeLauncher.scala)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.apache.spark.deploy.SparkSubmit$.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:804)
	at org.apache.spark.deploy.SparkSubmit$.doRunMain$1(SparkSubmit.scala:181)
	at org.apache.spark.deploy.SparkSubmit$.submit(SparkSubmit.scala:206)
	at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:120)
	at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
```

Periodic Job logs are included in the ticket (error.logs)	
