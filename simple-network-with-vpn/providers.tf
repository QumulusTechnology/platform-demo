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
  }
}
