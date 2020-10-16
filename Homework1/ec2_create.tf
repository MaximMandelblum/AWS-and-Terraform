
# Variables
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
    default = "us-east-2"
}

# provider
provider "aws" {
    profile =  "default"
    region =  var.region
}   

# default VPC 
resource "aws_default_vpc"  "default" {

}

# security groups to be able connect ngni from my pc
resource "aws_security_group" "allow_ssh" {
    name = "ngnix_ops"
    description = "allows ngnix port for working"
    vpc_id = aws_default_vpc.default.id

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
# creating EC2 instances and installing NGNIX
resource "aws_instance"  "opsschool_ec2" {

    ami = "ami-03657b56516ab7912"
    instance_type = "t2.micro"
    count = 2
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    
    tags = {
    Name  = "nginx-${count.index}"
    Owner = "Maxim"
    Porpuse = "Learning"
  }

    connection  { 

        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_path)

    }

    provisioner "remote-exec" {
      
        inline = [
            "sudo yum update -y",
            "sudo amazon-linux-extras install nginx1 -y",
            "sudo chmod 777 /usr/share/nginx/html/index.html",
            "sudo echo '<h1>OpsSchool Rules</h1>' > /usr/share/nginx/html/index.html",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx"
        
        ]
    }
}

# adding disk     
resource "aws_ebs_volume" "disk_add1" {
    availability_zone =  aws_instance.opsschool_ec2[0].availability_zone
    type = "gp2"
    size = 10
    encrypted = true
}
resource "aws_ebs_volume" "disk_add2" {
    availability_zone =  aws_instance.opsschool_ec2[1].availability_zone
    type = "gp2"
    size = 10
    encrypted = true
}
# Public DNS creation
output "aws_instance_public_dns1" {
        value = aws_instance.opsschool_ec2[0].public_dns
    }  
output "aws_instance_public_dns2" {
        value = aws_instance.opsschool_ec2[1].public_dns
    }  
