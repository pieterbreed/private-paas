resource "aws_instance" "cluster_master_node" {
  ami = "${lookup(var.amis, var.region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.consul.name}"]
  
  count = "${var.master_nodes_count}"
  instance_type = "${var.master_instance_type}"
  
  connection {
    user = "${var.ssh_username}"
    private_key = "${file("${var.key_path}")}"
  }  
  
  tags {
    Name = "Cluster Master Node - ${count.index + 1} / ${var.master_nodes_count}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y python language-pack-en"
    ]    
  }  
}
