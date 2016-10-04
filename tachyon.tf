provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "consul" {
  source = "github.com/hashicorp/consul/terraform/aws"
  key_name = "${var.key_name}"
  key_path = "${var.key_path}"
  region = "${var.region}"
  servers = "3"
}

resource "aws_instance" "app_server" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  tags {
    Name = "HelloWorld"    
  }  
  
}
