resource "aws_instance" "cluster_worker_node" {
  ami = "${lookup(var.amis, var.region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.consul.name}"]
  
  count = "${var.worker_nodes_count}"
  instance_type = "${var.worker_instance_type}"

  connection {
    user = "${var.ssh_username}"
    private_key = "${file("${var.key_path}")}"
  }  
  
  tags {
    Name = "${var.environment_name} - Worker Node - ${count.index + 1} / ${var.worker_nodes_count}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "timeout 180 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'",
      "sudo apt update && sudo apt install -y language-pack-en python"
    ]
  }  
}



