job "certbot" {
  datacenters = ["dc1"]
  type = "batch"
  periodic {
    cron = "*/5 * * * * *"
    prohibit_overlap = true
  }
  group "certbot" {
    count = 1
    ephemeral_disk {
      migrate = true
      size = "300"
      sticky = true
    }
    task "test" {
      driver = "exec"
      env {
	duration = "200"
      }
      config {
	#	command = "/bin/bash"
	command = "/bin/echo"
	args = ["letsencrypt", "certonly", "--standalone", "--config-dir", "/home/ubuntu/letsencrypt/etc", "--work-dir", "/home/ubuntu/letsencrypt/work", " --logs-dir", "/home/ubuntu/letsencrypt/log", "--standalone-supported-challenges", "http-01", "--http-01-port", "${NOMAD_PORT_http}", "-n", "--agree-tos", "--email", "pieter@ilovezoona.com", "-d", "vault.pb.co.za"]
#	args = ["-c", "echo port-http=${NOMAD_PORT_http};echo sleeping for $duration...; sleep $duration; echo slept"]
      }
      service {
	port = "http"
	tags ["urlprefix-vault.pb.co.za/"]
	  
      }
      resources {
	network {
	  port "http" {}
	  mbits = 1
	}
      }
    }
  }
}
