job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio-http" {
      driver = "exec"

      env {
	FABIO_REGISTRY_CONSUL_REGISTER_ADDR = ":${NOMAD_PORT_ui}"
	FABIO_PROXY_ADDR = ":${NOMAD_PORT_http}"
	FABIO_UI_ADDR = ":${NOMAD_PORT_ui}"
	FABIO_REGISTRY_CONSUL_TAGPREFIX = "http-urlprefix-"
	FABIO_REGISTRY_CONSUL_KVPATH = "/fabio/http-config"

      }
      config {
	command = "fabio-1.3.5-go1.7.3-linux_amd64"
      }

      artifact {
	source = "https://pieterbreed.keybase.pub/fabio-1.3.5-go1.7.3-linux_amd64"
	options {
	  checksum = "sha256:13da54805803011d97107a556ec425fc93c2023f5b3848b326cd3dc2a241a48f"
	}
      }

      resources {
	cpu = 500
	memory = 64
	network {
	  mbits = 1

	  port "http" {
	    static = 9993
	  }
	  port "ui" {
	    static = 9992
	  }
	}
      }
    }
    task "fabio-https" {
      driver = "exec"

      env {
	FABIO_REGISTRY_CONSUL_REGISTER_ADDR = ":${NOMAD_PORT_ui}"
	FABIO_PROXY_ADDR = ":${NOMAD_PORT_http};cs=sslcerts"
	FABIO_UI_ADDR = ":${NOMAD_PORT_ui}"
	FABIO_REGISTRY_CONSUL_TAGPREFIX = "https-urlprefix-"
	FABIO_PROXY_CS = "cs=sslcerts;type=consul;cert=http://localhost:8500/v1/kv/sslcerts"
	FABIO_REGISTRY_CONSUL_KVPATH = "/fabio/https-config"
      }
      config {
	command = "fabio-1.3.5-go1.7.3-linux_amd64"
      }

      artifact {
	source = "https://pieterbreed.keybase.pub/fabio-1.3.5-go1.7.3-linux_amd64"
	options {
	  checksum = "sha256:13da54805803011d97107a556ec425fc93c2023f5b3848b326cd3dc2a241a48f"
	}
      }

      resources {
	cpu = 500
	memory = 64
	network {
	  mbits = 1

	  port "http" {
	    static = 9991
	  }
	  port "ui" {
	    static = 9990
	  }
	}
      }
    }
  }
}

