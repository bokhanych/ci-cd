variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "java" {
    type = list
    default = ["22", "8080"]
}

variable "aws_key_pair_name" {
  type = string
  default = "tf_user"
}


/*
variable "app-server_ports" {
    type = list
    default = ["22", "8080"]
}
*/