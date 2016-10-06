provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "cluster_master_node" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.medium"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.consul.name}"]
  
  count = 3

  connection {
    user = "${var.ssh_username}"
    private_key = "${file("${var.key_path}")}"
  }  
  
  tags {
    Name = "Cluster Master Node - ${count.index}"
  }
  
  provisioner "file" {
    source = "server-install.sh"
    destination = "/tmp/server-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/server-install.sh",
      "sudo /tmp/server-install.sh"      
    ]
  }
}

resource "null_resource" "wire_master_cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.cluster_master_node.*.id)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(aws_instance.cluster_master_node.*.public_ip, 0)}"
    user = "${var.ssh_username}"
    private_key = "${file("${var.key_path}")}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "consul join ${join(" ", aws_instance.cluster_master_node.*.private_dns)}"      
      
    ]
  }
}

resource "aws_security_group" "consul" {
  name = "Hashistack"
  description = "Consul internal traffic + maintenance."

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    self = true
  }

  // These are for maintenance
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
