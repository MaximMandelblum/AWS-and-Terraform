#Security Groups 

resource "aws_security_group" "allow_ssh" {
    name = "ngnix_ops"
    description = "allows ngnix port for working"
    vpc_id = module.vpc.vpc_id


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

#S3 bucket creation for copy access log 

resource "aws_s3_bucket" "maxim_vpc_access" {
  bucket = "maxim_vpc_access"
  versioning {
    enabled = true
  }
}

##########################################
### INSTANCES WEB ###
##########################################

resource "aws_instance" "web" {
count = var.instance_number
ami = data.aws_ami.ubuntu-18.id
instance_type = "t2.micro"
key_name = var.key_name
iam_instance_profile = "access_s3"
subnet_id = module.vpc.public_subnet_ids[count.index]
associate_public_ip_address = true
vpc_security_group_ids = [aws_security_group.allow_ssh.id]
user_data = local.my-instance-userdata
tags = {
Name = "Web-${count.index}"
Owner = "Maxim"
Porpuse = "Learning"
}

}

##########################################
### INSTANCES DB ###
##########################################

resource "aws_instance" "db" {
count = var.instance_number
ami = data.aws_ami.ubuntu-18.id
instance_type = "t2.micro"
key_name = var.key_name
subnet_id = module.vpc.private_subnet_ids[count.index]
associate_public_ip_address = true
vpc_security_group_ids = [aws_security_group.allow_ssh.id]
tags = {
name = "db-${count.index}"
owner = "maxim"
porpuse = "learning"
}
}

# Load Balancer

resource "aws_elb" "web" {
name = "web-ngnix"
subnets = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
security_groups = [aws_security_group.allow_ssh.id]


listener {
instance_port = 80
instance_protocol = "http"
lb_port = 80
lb_protocol = "http"
}

health_check {
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 3
target = "HTTP:80/"
interval = 30
}
instances = aws_instance.web.*.id
cross_zone_load_balancing = true
idle_timeout = 400
connection_draining = true
connection_draining_timeout = 400

}

#stickiness for 1 min on web server that managed by LB
resource "aws_lb_cookie_stickiness_policy" "lb_stickiness" {
  name                     = "webservers-stickiness"
  load_balancer            = aws_elb.web.id
  lb_port                  = 80
  cookie_expiration_period = 60
}


#Public ELB DNS Name

output "aws_elb_public_dns" {
value = aws_elb.web.dns_name
}

