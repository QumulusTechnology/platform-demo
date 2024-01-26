locals {
  internal_network_cidr            = cidrsubnet(var.internal_network_range, 3, 0)
  internal_network_vpn_server_ip   = cidrhost(local.internal_network_cidr, 3)
  wireguard_network_cidr           = cidrsubnet(var.internal_network_range, 3, 1)
  wireguard_network_vpn_server_ip  = cidrhost(local.wireguard_network_cidr, 1)
  wireguard_network_remote_peer_ip = cidrhost(local.wireguard_network_cidr, 2)
  wireguard_network_cidr_prefix    = split("/", local.wireguard_network_cidr)[1]

}
