# Create a new load balancer
resource "aws_elb" "fabio" {
  
  availability_zones = ["${var.region}b"]
  security_groups = ["${aws_security_group.cluster.id}", "${aws_security_group.lb.id}"]

  listener {
    instance_port = 9991
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 9992
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:9990/health"
    interval = 10
  }

  instances = ["${aws_instance.cluster_worker_node.*.id}"]
  cross_zone_load_balancing = false
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.tld} ELB 2 fabio on workers"
  }
}
