resource "aws_security_group" "cluster" {
  name = "${var.tld}-cluster"
  description = "Open Internal Traffic + Maintenance."

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

resource "aws_security_group" "lb" {
  name = "${var.tld}-lb"
  description = "Incoming HTTP"

  // naked http
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
