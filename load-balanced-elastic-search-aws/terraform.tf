terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.35.0"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = ">= 0.2.5"
    }
  }
}
