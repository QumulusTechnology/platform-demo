
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

variable "vpn_image" {
  type    = string
  default = "Vyos-1.3-Equuleus"
}
variable "vpn_flavor" {
  type    = string
  default = "t1.micro"
}
variable "trusted_networks" {
  type        = list(string)
  description = "List of trusted remote networks for SSH Access - The default is unsecure, you should change this to your own trusted networks"
}
