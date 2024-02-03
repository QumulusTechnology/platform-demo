resource "openstack_networking_network_v2" "internal_kubernetes" {
  name        = "internal-kubernetes"
  description = "Used for Kubernetes clusters that are intended for internal use behind the Firewall and accessed through the VPN"
}

resource "openstack_networking_subnet_v2" "internal_kubernetes" {
  name        = "internal-kubernetes-subnet"
  ip_version  = 4
  network_id  = openstack_networking_network_v2.internal_kubernetes.id
  cidr        = local.internal_kubernetes_network_cidr
  enable_dhcp = true
  no_gateway  = false
}

resource "openstack_networking_network_v2" "internal_kubernetes_lb" {
  name        = "internal-kubernetes-load-balancers"
  description = "Used to host the load balancers for Kubernetes clusters that are intended for internal use behind the Firewall and accessed through the VPN"
  external    = true
}

resource "openstack_networking_subnet_v2" "internal_kubernetes_lb" {
  name        = "internal-kubernetes-load-balancers-subnet"
  ip_version  = 4
  network_id  = openstack_networking_network_v2.internal_kubernetes_lb.id
  cidr        = local.internal_kubernetes_lb_network_cidr
  enable_dhcp = true
  no_gateway  = false
}

resource "openstack_networking_router_v2" "internal_kubernetes_router" {
  name                = "internal-kubernetes-router"
  external_network_id = openstack_networking_network_v2.internal_kubernetes_lb.id
  external_fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal_kubernetes_lb.id
    ip_address = cidrhost(local.internal_kubernetes_lb_network_cidr, 254)
  }
  enable_snat = false
}

resource "openstack_networking_port_v2" "internal_kubernetes_router_port" {
  name       = "internal-kubernetes-router-port"
  network_id = openstack_networking_network_v2.internal_kubernetes.id
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal_kubernetes.id
    ip_address = cidrhost(local.internal_kubernetes_network_cidr, 1)
  }
}

resource "openstack_networking_router_interface_v2" "internal_kubernetes_router_internal_kubernetes_network_port_attachment" {
  router_id = openstack_networking_router_v2.internal_kubernetes_router.id
  port_id   = openstack_networking_port_v2.internal_kubernetes_router_port.id
}

resource "openstack_networking_port_v2" "public_router_internal_kubernetes_lb_network_port" {
  name       = "public-router-internal-kubernetes-lb-network-port"
  network_id = openstack_networking_network_v2.internal_kubernetes_lb.id
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal_kubernetes_lb.id
    ip_address = cidrhost(local.internal_kubernetes_lb_network_cidr, 1)
  }
}

resource "openstack_networking_router_interface_v2" "public_router_internal_kubernetes_lb_network_port_attachment" {
  router_id = var.public_router_id
  port_id   = openstack_networking_port_v2.public_router_internal_kubernetes_lb_network_port.id
}

resource "openstack_networking_router_route_v2" "internal_kubernetes_router_route" {
  router_id        = var.public_router_id
  destination_cidr = local.internal_kubernetes_network_cidr
  next_hop         = cidrhost(local.internal_kubernetes_lb_network_cidr, 254)
  depends_on = [
    openstack_networking_router_interface_v2.internal_kubernetes_router_internal_kubernetes_network_port_attachment
  ]
}
