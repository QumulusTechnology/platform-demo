### This section is for variables that are specific to your environment and you should create a `terraform.tfvars` file to set these variables
### You can use the `terraform.tfvars.example` file as a template

variable "ece_domain" {
  type        = string
  description = "Domain name to access elastic. Please set this to something real and point it to the load balancer floating IP address"
}

variable "lets_encrypt_email" {
  type        = string
  description = "email address used for letsencrypt cert request"
}

variable "path_to_openstack_rc" {
  type        = string
  description = "path for your OpenStack credentials"
}

variable "public_ssh_key_path" {
  type        = string
  description = "path to your public ssh key"
}

variable "private_ssh_key_path" {
  type        = string
  description = "path to your private ssh key"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_availability_zone_1" {
  type    = string
  default = "us-east-1a"
}

variable "aws_availability_zone_2" {
  type    = string
  default = "us-east-1b"
}

#####################################################################

variable "trusted_networks" {
  type        = list(string)
  description = "List of trusted remote networks for VPN/Elasticsearch access"
  default     = ["0.0.0.0/0"]
}

variable "public_network_name" {
  type    = string
  default = "public"
}

variable "internal_network_range" {
  type    = string
  default = "192.168.64.0/21"
}

variable "ssh_key_name" {
  type    = string
  default = "my-key-pair"
}

variable "run_ansible" {
  type        = bool
  description = "run ansible automatically - set to false if you want to run the installation manually after the deployment - this can be useful for debugging and troubleshooting"
  default     = true
}
