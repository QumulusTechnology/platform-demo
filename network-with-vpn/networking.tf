resource "openstack_networking_router_v2" "public" {
  name                = "public-router"
  external_network_id = data.openstack_networking_network_v2.public.id
  enable_snat         = true
}

### Internal network for VMs
### It is defined as external (An OpenStack term that enables the floating IP feature) so the Kubernetes can use it for load balancers
resource "openstack_networking_network_v2" "internal" {
  name = "internal"
  external = true
}

resource "openstack_networking_subnet_v2" "internal" {
  name        = "internal-subnet"
  ip_version  = 4
  network_id  = openstack_networking_network_v2.internal.id
  cidr        = local.internal_network_cidr
  enable_dhcp = true
  no_gateway  = false
}

resource "openstack_networking_router_interface_v2" "router_internal_interface" {
  router_id = openstack_networking_router_v2.public.id
  subnet_id = openstack_networking_subnet_v2.internal.id
}
