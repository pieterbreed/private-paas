job "api-gateway" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "api-gateway" {
    count = 1

    task "api-gateway" {
      driver = "java"
      config {
      	     jar_path = "local/api-gateway.jar"
      }

      env {
	VAULT_ADDR = "https://vault.1.zoona.network"
	KAFKA_ADDR = "ip-172-31-12-99.ec2.internal:9092,ip-172-31-14-9.ec2.internal:9092,ip-172-31-15-202.ec2.internal:9092
"
      }

      artifact {
        source = "https://pieterbreed.keybase.pub/api-gateway.jar"
        options {
          checksum = "sha256:29ef5f707405d73423c7a40a3045efb964102aee6964475a1825fdab95741723"
        }
      }

      resources {
        cpu = 500
        memory = 1024
        network {
          mbits = 1
	  port "http" {
	    static = 8080
	  }
        }
      }

      service {
        name = "api-gateway"
        tags = ["https-urlprefix-gw.1.zoona.network/"]
        port = "http"
	check {
	  type = "script"
	  name = "bintrue"
	  command = "/bin/true"
	  interval = "1s"
	  timeout  = "2s"
	}
      }
    }
  }
}
