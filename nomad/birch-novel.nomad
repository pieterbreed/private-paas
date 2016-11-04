job "birch-novel" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "birch-novel" {
    count = 3

    task "birch-novel" {
      driver = "java"
      config {
      	     jar_path = "local/birch-novel-0.2.3-standalone.jar"
	     args = ["-u", "datomic:mem://test", "daemon"]
      }

      env {
        METRICS_PORT = "${NOMAD_PORT_http}"
      }

      artifact {
        source = "https://pieterbreed.keybase.pub/birch-novel-0.2.3-standalone.jar"
        options {
          checksum = "sha256:2a24160e0341715e8e2366f7dfe580b36073739836cc942365382f2b6d26cb77"
        }
      }

      resources {
        cpu = 500
        memory = 512
        network {
          mbits = 1
          port "http" {}
        }
      }

      service {
        name = "birch-novel"
        tags = ["urlprefix-/birch-novel"]
        port = "http"
        check {
          type = "http"
          name = "birch-novel"
          interval = "15s"
          timeout = "5s"
          path = "/"
        }
      }
    }
  }
}
