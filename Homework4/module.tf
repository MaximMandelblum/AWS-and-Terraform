module "vpc" {
  source = "git@github.com:MaximMandelblum/elephent_vpc.git"

  aws_region = "us-east-1"
  subnet1_public = ["10.0.1.0/24" , "10.0.50.0/24"]
  subnet2_private = ["10.0.100.0/24", "10.0.150.0/24"]
  vpc_name = "example-vpc"
  cidr_network = "10.0.0.0/16"

}
