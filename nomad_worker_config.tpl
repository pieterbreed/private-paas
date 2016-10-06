addresses {
    rpc  = "${worker_ip}"
    http = "${worker_ip}"
}

advertise {
    http = "${worker_ip}:4646"
    rpc  = "${worker_ip}:4647"
}

data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

client {
    enabled = true
    servers = [
    ${nomad_master_list}
    ]
    options {
        "driver.raw_exec.enable" = "1"
    }
}
