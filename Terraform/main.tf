provider "aws" {
  profile                 = "default"
  region                  = "eu-central-1"
}

resource "aws_instance" "jenkins" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    tags = { Name = "JENKINS" }
    vpc_security_group_ids = [aws_security_group.java.id]
    key_name        = data.aws_key_pair.selected.key_name
    user_data = <<EOF
#!/bin/bash
# Jenkins install
sudo apt update -y;
sudo apt install default-jdk maven net-tools -y;
echo "deb https://pkg.jenkins.io/debian-stable binary/" > jenkins.list;
sudo mv jenkins.list /etc/apt/sources.list.d/;
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -;
sudo mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/;
sudo apt update -y;
sudo apt install jenkins -y;
sudo systemctl enable --now jenkins;
EOF
}

resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    tags = { Name = "APP-SERVER" }
    vpc_security_group_ids = [aws_security_group.java.id]
    key_name        = data.aws_key_pair.selected.key_name
    user_data = <<EOF
#!/bin/bash
# Docker install
sudo apt update -y;
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y;
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
EOF
}

resource "aws_security_group" "java" {
  name = "app-server Security Group"
  description = "Open SSH, HTTP, HTTPS port"
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