variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "key_name" {
  default = "max_terraform"
  type = string
}


variable "instance_type" {
  description = "The type of the ec2, for example - t2.micro"
  type        = string
  default     = "t2.micro"
}


variable "cidr_network" {

    default = "10.0.0.0/16"
}

variable "subnet1_public" {

    default = ["10.0.1.0/24" , "10.0.50.0/24"]
}

variable "subnet2_private" {

    default = ["10.0.100.0/24", "10.0.150.0/24"]
}
variable "private_key_path" {}

