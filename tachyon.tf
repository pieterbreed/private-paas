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
  key_name = "${var.key_name}"
  tags {
    Name = "HelloWorld"    
  }

  provisioner "remote-exec" {
    connection = {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(var.key_path)}"      
    }    
    inline = [
      # install oracle java 1.8      
      "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",
      "sudo add-apt-repository -y ppa:webupd8team/java",
      "sudo apt-get update",
      "sudo apt-get install -y oracle-java8-installer",

      # install leiningen      
      "curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > lein",
      "chmod +x lein",
      "sudo mkdir -p /usr/local/bin",
      "sudo mv lein /usr/local/bin"
    ]    
  }  
}
