

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

# Routing IGW Configuration

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


#Nat Gateway Creation

resource "aws_eip" "ip_nat"{
  vpc = "true"
  count = 2 
}

resource "aws_nat_gateway" "gw_nat" {
  count = 2
  allocation_id = aws_eip.ip_nat[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.vpc_igw]



  tags = {
    Name = "MyNAT"
  }
}

#Routing Nat Configurationm

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

#Security Groups 

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
### INSTANCES WEB ###
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

##########################################
### INSTANCES DB ###
##########################################

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

# Load Balancer

resource "aws_elb" "web" {
  name = "web-ngnix" 
  subnets = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  security_groups = [aws_security_group.allow_ssh.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  
  instances                   = aws_instance.web.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  

}

#Public ELB DNS Name 

output "aws_elb_public_dns" {
  value = aws_elb.web.dns_name
}
