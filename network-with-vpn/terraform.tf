terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.54.1"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = ">= 0.2.2"
    }
  }
}
