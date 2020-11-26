resource "aws_instance" "consul_server" {
  count         = var.instance_server_number
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.consul.id]
  user_data = file("scripts/consul-server.sh")

  tags = {
    Name = "consul-server"
    consul_server = "true"
  }

}

resource "aws_instance" "consul_agent" {

  count         = var.instance_agent_number
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.consul.id]
  user_data = file("scripts/consul-agent.sh")
  tags = {
    Name = "consul-agent"
  }
}

output "server" {
  value = aws_instance.consul_server.*.public_dns
}

output "agent" {
  value = aws_instance.consul_agent.public_dns
}
