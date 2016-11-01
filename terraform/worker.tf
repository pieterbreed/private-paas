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
    Name = "Cluster Worker Node - ${count.index + 1} / ${var.worker_nodes_count}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install language-pack-UTF-8",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y python language-pack-en"
    ]    
  }  
}



