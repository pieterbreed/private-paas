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
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y python language-pack-en"
    ]    
  }  
}

# # configuration for nomad, destined for /etc/nomad/client.hcl
# data "template_file" "cluster_worker_node_nomad_config" {
#   count = "${var.worker_nodes_count}"
#   template = "${file("nomad_worker_config.tpl")}"

#   vars {
#     nomad_master_list = "${join(",", formatlist("\"%s\"", aws_instance.cluster_master_node.*.private_dns))}"
#     worker_ip = "${element(aws_instance.cluster_worker_node.*.private_ip, count.index)}"
#   }  
# }

# resource "null_resource" "cluster_worker_nomad_config" {
#   count = "${var.worker_nodes_count}"  

#   # Changes to id of worker node requires re-provisioning
#   triggers {
#     template_content = "${element(data.template_file.cluster_worker_node_nomad_config.*.rendered, count.index)}"
#   }
  
#   connection {
#     host = "${element(aws_instance.cluster_worker_node.*.public_ip, count.index)}"
#     user = "${var.ssh_username}"
#     private_key = "${file("${var.key_path}")}"
#   }  

#   # copy the rendered config file over (specific to each worker node)  
#   provisioner "file" {
#     content = "${element(data.template_file.cluster_worker_node_nomad_config.*.rendered, count.index)}"
#     destination = "client.hcl"
#   }

#   # resume the rest of the installation...  
#   provisioner "file" {
#     source = "worker-install.sh"
#     destination = "/tmp/worker-install.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo chmod +x /tmp/worker-install.sh",
#       "sudo /tmp/worker-install.sh",
#       "sudo systemctl restart nomad"      
#     ]
#   }

# }


