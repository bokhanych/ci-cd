data "aws_ami" "latest_ubuntu" {
    owners = ["099720109477"]
    most_recent = true
    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

data "aws_key_pair" "selected" {
  key_name           = var.aws_key_pair_name
  include_public_key = true
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}