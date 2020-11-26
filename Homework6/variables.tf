variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}

variable "key_name" {
  description = "name of ssh key to attach to hosts"
}

variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
  }

}

variable "instances_number" {
  description = "Number of ec2 needed"
  default = 3
  type = string
}

variable "cidr_network" {

    default = "10.0.0.0/16"
}

variable "consul_public" {

    default = ["10.0.1.0/24"]
}