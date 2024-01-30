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
