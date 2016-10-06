addresses {
    rpc  = "${var.worker_ip}"
    http = "${var.worker_ip}"
}

advertise {
    http = "${var.worker_ip}:4646"
    rpc  = "${var.worker_ip}:4647"
}

data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

client {
    enabled = true
    servers = [
    ${var.nomad_master_list}
    ]
    options {
        "driver.raw_exec.enable" = "1"
    }
}
