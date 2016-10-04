provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "consul" {
  source = "git::https://github.com/hashicorp/consul//terraform/aws?ref=v0.7.0"
  key_name = "${var.key_name}"
  key_path = "${var.key_path}"
  region = "${var.region}"
  servers = "3"
}

resource "aws_instance" "app_server" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.consul.name}"]  
  tags {
    Name = "HelloWorld"    
  }

  provisioner "remote-exec" {
    connection = {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(var.key_path)}"      
    }    
  }  
}

resource "aws_security_group" "consul" {
  name = "consul_app_servers"
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
