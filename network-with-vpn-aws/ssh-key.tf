resource "aws_key_pair" "this" {
  public_key = file(var.public_ssh_key_path)
}
