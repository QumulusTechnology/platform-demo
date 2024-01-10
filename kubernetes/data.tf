data "openstack_compute_keypair_v2" "this" {
  name = var.keypair_name
}

data "openstack_networking_network_v2" "public" {
  name = var.public_network_name
}
