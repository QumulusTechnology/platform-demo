data "aws_ami" "vyos" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.aws_ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.aws_ami_owner]
}
