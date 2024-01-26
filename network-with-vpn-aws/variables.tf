
variable "public_network_name" {
  type    = string
}

variable "internal_network_range" {
  type    = string
}

variable "public_ssh_key_path" {
  type    = string
}

variable "ssh_key_name" {
  type    = string
}

variable "vpn_flavor" {
  type    = string
  default = "t3.small"
}
variable "trusted_networks" {
  type        = list(string)
  description = "List of trusted remote networks for SSH Access - The default is unsecure, you should change this to your own trusted networks"
}

variable "project_name" {
  type = string
  default = "ece-benchmark"
}

variable "aws_ami_name" {
  type = string
  default = "VyOS 1.3*"
}

variable "aws_ami_owner" {
  type = string
  default = "679593333241"
}

variable "aws_region" {
  type = string
}

variable "aws_availability_zone_1" {
  type = string
}

variable "aws_availability_zone_2" {
  type = string
}
