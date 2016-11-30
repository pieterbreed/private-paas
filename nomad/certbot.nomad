job "certbot" {
  datacenters = ["dc1"]
  type = "batch"
  group "certbot" {
    count = 1
    ephemeral_disk {
      migrate = true
      size = "300"
      sticky = true
    }
    task "letsencrypt" {
      driver = "exec"
      env {
      }
      config {
	command = "/usr/bin/letsencrypt"
	args = ["certonly", "--standalone", "--config-dir", "${NOMAD_ALLOC_DIR}/letsencrypt/etc", "--work-dir", "${NOMAD_ALLOC_DIR}/letsencrypt/work", "--logs-dir", "${NOMAD_ALLOC_DIR}/letsencrypt/log", "--standalone-supported-challenges", "http-01", "--http-01-port", "${NOMAD_PORT_http}", "-n", "--agree-tos", "--email", "pieter@ilovezoona.com", "-d", "vault.pb.co.za"]
      }
      service {
	port = "http"
	tags = ["urlprefix-vault.pb.co.za/.well-known/acme-challenge"]
	check {
	  type = "script"
	  name = "bintrue"
	  command = "/bin/true"
	  interval = "1s"
	  timeout  = "2s"
	}
      }
      resources {
	cpu = 500
	memory = 512
	network {
	  port "http" {}
	  mbits = 1
	}
      }
    }
  }
}
