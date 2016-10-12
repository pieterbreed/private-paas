output "master_nodes_public" {
  value = ["${aws_instance.cluster_master_node.*.public_dns}"]
}

output "worker_nodes_public" {
  value = ["${aws_instance.cluster_worker_node.*.public_dns}"]
}

output "master_nodes_private" {
  value = ["${aws_instance.cluster_master_node.*.private_dns}"]
}

output "worker_nodes_private" {
  value = ["${aws_instance.cluster_worker_node.*.private_dns}"]
}
