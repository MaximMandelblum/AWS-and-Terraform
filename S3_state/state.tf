provider "aws" {
  region = "us-east-1"
}



 
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "maxim-1983-1983"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    
  }
}