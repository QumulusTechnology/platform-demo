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

resource "openstack_networking_network_v2" "public_kubernetes" {
  name        = "public-kubernetes"
  description = "Used for Kubernetes clusters that are intended for Internet facing services and require a load balancer with a valid public IP"
}

resource "openstack_networking_subnet_v2" "public_kubernetes" {
  name        = "public-kubernetes-subnet"
  ip_version  = 4
  network_id  = openstack_networking_network_v2.public_kubernetes.id
  cidr        = local.public_kubernetes_network_cidr
  enable_dhcp = true
  no_gateway  = false
}

resource "openstack_networking_router_v2" "internal_kubernetes_router" {
  name                = "internal-kubernetes-router"
  external_network_id = var.internal_network_id
  external_fixed_ip {
    subnet_id  = var.internal_subnet_id
    ip_address = cidrhost(local.internal_network_cidr, 254)
  }
  enable_snat = true
}

resource "openstack_networking_port_v2" "internal_kubernetes_router_internal_kubernetes_network_port" {
  name       = "internal-kubernetes-router-internal-kubernetes-network-port"
  network_id = openstack_networking_network_v2.internal_kubernetes.id
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal_kubernetes.id
    ip_address = cidrhost(local.internal_kubernetes_network_cidr, 1)
  }
}

resource "openstack_networking_router_interface_v2" "internal_kubernetes_router_internal_kubernetes_network_port" {
  router_id = openstack_networking_router_v2.internal_kubernetes_router.id
  port_id   = openstack_networking_port_v2.internal_kubernetes_router_internal_kubernetes_network_port.id
}

resource "openstack_networking_port_v2" "public_router_internal_kubernetes_network_port" {
  name       = "public-router-internal-kubernetes-network-port"
  network_id = openstack_networking_network_v2.internal_kubernetes.id
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal_kubernetes.id
    ip_address = cidrhost(local.internal_kubernetes_network_cidr, 254)
  }
}

resource "openstack_networking_router_interface_v2" "public_router_internal_kubernetes_network_port" {
  router_id = var.public_router_id
  port_id   = openstack_networking_port_v2.public_router_internal_kubernetes_network_port.id
}

resource "openstack_networking_port_v2" "public_router_public_kubernetes_network_port" {
  name       = "public-router-public-kubernetes-network-port"
  network_id = openstack_networking_network_v2.public_kubernetes.id
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.public_kubernetes.id
    ip_address = cidrhost(local.public_kubernetes_network_cidr, 1)
  }
}

resource "openstack_networking_router_interface_v2" "public_router_public_kubernetes_network_port" {
  router_id = var.public_router_id
  port_id   = openstack_networking_port_v2.public_router_public_kubernetes_network_port.id
}

resource "openstack_networking_router_route_v2" "internal_kubernetes_router_route" {
  router_id        = openstack_networking_router_v2.internal_kubernetes_router.id
  destination_cidr = cidrsubnet(var.internal_network_range, 1, 0)
  next_hop         = openstack_networking_port_v2.public_router_internal_kubernetes_network_port.fixed_ip[0].ip_address
  depends_on = [
    openstack_networking_router_interface_v2.internal_kubernetes_router_internal_kubernetes_network_port
  ]
}
