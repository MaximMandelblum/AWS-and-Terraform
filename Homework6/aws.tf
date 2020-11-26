provider "aws" {
  region = var.region
  profile = "imperva"
}

# VPC Creation

resource "aws_vpc"  "vpc_main" {

  cidr_block =  var.cidr_network
  enable_dns_hostnames = "true"
  tags = {
    Name = "myVpc"
  }

}
# Internet Gateway Creation

resource "aws_internet_gateway"  "vpc_igw" {

  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "myIGW"
  }
}


# Subnets configuration

resource "aws_subnet"  "public_subnet" {
  cidr_block = var.consul_public
  vpc_id = aws_vpc.vpc_main.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names
  tags =  {
    Name = "PublicSubnet"
  }
}

# Routing IGW Configuration

resource "aws_route_table" "rt_public"{

  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
    }

} 

resource "aws_route_table_association" "rta-subnet1-public" {

  subnet_id = aws_subnet.public_subnet.id 
  route_table_id = aws_route_table.rt_public.id 
}



resource "aws_security_group" "consul" {
  name        = "consul_sg"
  description = "Allow ssh & consul inbound traffic"
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access from the world"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "consul-join-role"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-join-policy"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join-policy-attach"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "consul-join-profile"
  role = aws_iam_role.consul-join.name
}
