variable "internal_network_id" {
  type = string
}

variable "internal_subnet_id" {
  type = string
}

variable "public_network_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "vpn_security_group_id" {
  type = string
}

variable "internal_network_range" {
  type    = string
}

variable "public_router_id" {
  type = string
}

variable "node_flavor" {
  type = string
  default = "t1.xlarge"
}

variable "master_flavor" {
  type = string
  default = "t1.medium"
}

variable "docker_volume_size" {
  type = string
  description = "Size in GB of the docker volume"
  default = "100"
}

variable "kube_tag" {
  type = string
  default = "v1.27.8-rancher2"
}

variable "kube_image_name" {
  type = string
  default = "Fedora-Core-Stable"
}

variable "master_count" {
  type = number
  default = 1
}

variable "node_count" {
  type = number
  default = 1
}

variable "min_node_count" {
  type = number
  default = 1
}

variable "max_node_count" {
  type = number
  default = 3
}
