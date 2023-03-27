variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "app-server_ports" {
    type = list
    default = ["22", "8080"]
}

variable "jenkins_ports" {
    type = list
    default = ["22", "8080"]
}