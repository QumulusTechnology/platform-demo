terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.53.0"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.2.2"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "0.2.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
    
  }
}

provider "openstack" {
  user_name   = data.external.read_openstack_rc.result["OS_USERNAME"]
  tenant_name = data.external.read_openstack_rc.result["OS_PROJECT_NAME"]
  password    = data.external.read_openstack_rc.result["OS_PASSWORD"]
  auth_url    = data.external.read_openstack_rc.result["OS_AUTH_URL"]
  region      = "RegionOne"
}

provider "aws" {
  region = var.aws_region
}
