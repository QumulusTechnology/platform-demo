terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.53.0"
    }
    pkcs12 = {
      source = "chilicat/pkcs12"
      version = "0.2.5"
    }
  }
}
