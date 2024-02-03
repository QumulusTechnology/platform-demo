variable "domain" {
  type = string
  validation {
    condition     = var.domain != "yourdomain.com"
    error_message = "Please add a valid domain to your terraform.tfvars file"
  }
}

variable "letsencrypt_email" {
  type        = string
  description = "email address used for letsencrypt cert request"
}

variable "deploy_internal_cluster_helm_charts" {
  type        = bool
  description = "deploy any helm charts to the internal cluster (the VPN needs to be connected for this to work)"
}
