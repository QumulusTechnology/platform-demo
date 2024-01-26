data "openstack_networking_network_v2" "public" {
  name = var.public_network_name
}

data "openstack_images_image_v2" "vpn" {
  name        = var.vpn_image
  most_recent = true
}

data "openstack_compute_flavor_v2" "vpn" {
  name = var.vpn_flavor
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}
