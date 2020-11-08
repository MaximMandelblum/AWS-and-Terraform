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

variable "private_key_path" {}
