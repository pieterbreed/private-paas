job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "exec"
      config {
        command = "fabio"
      }

      artifact {
        source = "https://keybase.pub/pieterbreed/fabio-1.3.3-go1.7.1-linux_amd64"
        options {
          checksum = "sha256:b4039172e7eff89b7a77ba0721cf0543473cf4bfaf502d72e6407f9aa619a3f6"
        }
      }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
