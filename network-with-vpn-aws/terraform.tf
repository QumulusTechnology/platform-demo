terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.35.0"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = ">= 0.2.2"
    }
  }
}
