locals {
  vpc_cidr                         = cidrsubnet(var.internal_network_range, 1, 0)
  public_network_cidr_1          = cidrsubnet(var.internal_network_range, 3, 0)
  public_network_cidr_2          = cidrsubnet(var.internal_network_range, 3, 1)
  private_network_cidr_1          = cidrsubnet(var.internal_network_range, 3, 2)
  private_network_cidr_2          = cidrsubnet(var.internal_network_range, 3, 3)
  internal_network_vpn_server_ip   = cidrhost(local.public_network_cidr_1, 10)
  wireguard_network_cidr           = cidrsubnet(var.internal_network_range, 3, 4)
  wireguard_network_vpn_server_ip  = cidrhost(local.wireguard_network_cidr, 1)
  wireguard_network_remote_peer_ip = cidrhost(local.wireguard_network_cidr, 2)
  wireguard_network_cidr_prefix    = split("/", local.wireguard_network_cidr)[1]

}
