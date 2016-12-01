variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "key_path" {}
variable "tld" {}

variable "region" {
  default = "us-east-1"
}

variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"    
  }
}

variable ssh_username {
  default = "ubuntu"
}

variable datomic_nodes_count {
  default = 1
}

variable datomic_instance_type {
  default = "t2.medium"
}

variable master_nodes_count {
  default = 3
}
variable master_instance_type {
  default = "t2.medium"
}

variable worker_nodes_count {
  default = 3
}
variable worker_instance_type {
  default = "t2.medium"
}
