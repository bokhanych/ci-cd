provider "aws" {
  profile                 = "default"
  region                  = "eu-central-1"
}

resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    tags = { Name = "APP-SERVER" }
    vpc_security_group_ids = [aws_security_group.java.id]
    key_name        = data.aws_key_pair.selected.key_name
    user_data = "${file("scripts/docker-install.sh")}"
}

resource "aws_security_group" "java" {
  name = "app-server Security Group"
  description = "Open SSH and 8080 port"
    dynamic "ingress" {
    for_each = var.java
    content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]    
    }
}