terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.54.1"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = ">= 0.2.5"
    }
  }
}
