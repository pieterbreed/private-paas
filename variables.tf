variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "key_path" {}

variable "region" {
  default = "us-east-1"
}

variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
  }
}

variable ssh_username {
  default = "ubuntu"
}

variable master_nodes_count {
  default = 3
}
variable master_instance_type {
  default = "t2.micro"
}

variable worker_nodes_count {
  default = 1
}
variable worker_instance_type {
  default = "t2.micro"
}
