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
