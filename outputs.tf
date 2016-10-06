output "master_node_0" {
  value = "${var.ssh_username}@${aws_instance.cluster_master_node.0.public_dns}"
}
