variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "java" {
    type = list
    default = ["22", "8080", "3000", "9090", "9100"]
}

variable "aws_key_pair_name" {
  type = string
  default = "tf_user"
}