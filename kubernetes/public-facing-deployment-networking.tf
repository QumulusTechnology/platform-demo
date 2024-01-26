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
