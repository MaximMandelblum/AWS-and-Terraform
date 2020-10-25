

# VPC config
resource "aws_vpc"  "vpc_main" {

  cidr_block =  var.cidr_network 
  enable_dns_hostnames = "true"
  tags = {
    Name = "myVpc"
  }

}
# Internet Gateway Config
resource "aws_internet_gateway"  "vpc_igw" {

  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "myIGW"
  }  
}

#Nat Gateway 

resource "aws_eip" "ip_nat"{
  vpc = "true"
  count = 2 
}

resource "aws_nat_gateway" "gw_nat" {
  count = 2
  allocation_id = aws_eip.ip_nat[count.index].id

  subnet_id = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "MyNAT"
  }
}

# Subnets config
resource "aws_subnet"  "public_subnet" {
  count = 2
  cidr_block = var.subnet1_public[count.index]
  vpc_id = aws_vpc.vpc_main.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags =  {
    Name = "PublicSubnet"
  }
}


resource "aws_subnet"  "private_subnet" {
  count = 2
  cidr_block = var.subnet2_private[count.index]
  vpc_id = aws_vpc.vpc_main.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "PrivateSubnet"
  }
}

# Routing IGW

resource "aws_route_table" "rt_public"{
  count = 2
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
    }

}

resource "aws_route_table_association" "rta-subnet1-public" {

  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id 
  route_table_id = aws_route_table.rt_public[count.index].id 
}

#Routing Nat

resource "aws_route_table" "rt_private"{
  vpc_id = aws_vpc.vpc_main.id
  count =2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw_nat[count.index].id
    }

}

resource "aws_route_table_association" "rta-subnet2-private" {
  count = 2
  subnet_id = aws_subnet.private_subnet[count.index].id 
  route_table_id = aws_route_table.rt_private[count.index].id 
}

#security Groups 

resource "aws_security_group" "allow_ssh" {
    name = "ngnix_ops"
    description = "allows ngnix port for working"
    vpc_id = aws_vpc.vpc_main.id

    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress  {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

##########################################
### INSTANCES ###
##########################################

resource "aws_instance" "web" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu-18.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.*.id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  user_data = local.my-instance-userdata
  tags = {
    Name  = "Web-${count.index}"
    Owner = "Maxim"
    Porpuse = "Learning"
  }

}


resource "aws_instance" "db" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu-18.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private_subnet.*.id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name  = "DB-${count.index}"
    Owner = "Maxim"
    Porpuse = "Learning"
  }
}


