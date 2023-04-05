#!/bin/bash
# Jenkins install for Ubuntu
sudo apt update -y;
sudo apt install default-jdk maven net-tools -y;
echo "deb https://pkg.jenkins.io/debian-stable binary/" > jenkins.list;
sudo mv jenkins.list /etc/apt/sources.list.d/;
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -;
sudo mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/;
sudo apt update -y;
sudo apt install jenkins -y;
sudo systemctl enable jenkins && sudo systemctl start jenkins
# Docker install for Ubuntu
sudo apt update -y;
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y;
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker jenkins && sudo chmod 666 /var/run/docker.sock