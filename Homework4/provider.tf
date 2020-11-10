provider "aws" {
  profile = "imperva"
  region     = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "maxim-1983-1983"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}