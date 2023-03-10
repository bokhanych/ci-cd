resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    tags = { Name = "APP-SERVER" }
    vpc_security_group_ids = [aws_security_group.app-server_security_group.id]
}

resource "aws_instance" "jenkins" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    tags = { Name = "JENKINS" }
    vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]
}

resource "aws_security_group" "app-server_security_group" {
  name = "app-server Security Group"
  description = "Open SSH, HTTP, HTTPS port"

    dynamic "ingress" {
    for_each = var.app-server_ports
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

resource "aws_security_group" "jenkins_security_group" {
  name = "jenkins Security Group"
  description = "Open SSH, Java port"
    depends_on = [ aws_security_group.app-server_security_group ]
    dynamic "ingress" {
    for_each = var.jenkins_ports
    content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        security_groups = [aws_security_group.app-server_security_group.id]
    }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]    
    }
}