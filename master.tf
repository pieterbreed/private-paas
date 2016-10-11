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
  
  # provisioner "file" {
  #   source = "master-install.sh"
  #   destination = "/tmp/master-install.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo chmod +x /tmp/master-install.sh",
  #     "sudo /tmp/master-install.sh"      
  #   ]
  # }
}

# resource "null_resource" "wire_master_cluster" {
#   # Changes to any instance of the cluster requires re-provisioning
#   triggers {
#     cluster_instance_ids = "${join(",", aws_instance.cluster_master_node.*.id)}"
#   }

#   # Bootstrap script can run on any instance of the cluster
#   # So we just choose the first in this case
#   connection {
#     host = "${element(aws_instance.cluster_master_node.*.public_ip, 0)}"
#     user = "${var.ssh_username}"
#     private_key = "${file("${var.key_path}")}"
#   }

#   provisioner "remote-exec" {
#     # Bootstrap script called with private_ip of each node in the clutser
#     inline = [
#       "consul join ${join(" ", aws_instance.cluster_master_node.*.private_dns)}",
#       "nomad server-join ${join(" ", aws_instance.cluster_master_node.*.private_dns)}"
#     ]
#   }
# }
