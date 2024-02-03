### This section is for variables that are specific to your environment and you should create a `terraform.tfvars` file to set these variables
### You can use the `terraform.tfvars.example` file as a template

variable "ece_domain" {
  type        = string
  description = "Domain name to access elastic. Please set this to something real and point it to the load balancer floating IP address"
}

variable "letsencrypt_email" {
  type        = string
  description = "email address used for letsencrypt cert request"
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

variable "calculate_aws_costs" {
  type    = bool
  default = false
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

variable "update_kube_config" {
  type        = bool
  default     = false
  description = "Update your kubeconfig file with access details of the new kubernetes clusters"
}

variable "domain" {
  type    = string
  default = "yourdomain.com"
}

variable "deploy_network_with_vpn" {
  type    = bool
  default = true
}

variable "deploy_network_with_vpn_aws" {
  type    = bool
  default = false
}

variable "deploy_ece" {
  type    = bool
  default = true
}

variable "deploy_ece_aws" {
  type    = bool
  default = false
}

variable "deploy_kubernetes" {
  type    = bool
  default = false
}

variable "deploy_argocd" {
  type    = bool
  default = false
}

variable "deploy_internal_cluster_helm_charts" {
  type        = bool
  default     = false
  description = "deploy any helm charts to the internal cluster (the VPN needs to be connected for this to work)"
}
