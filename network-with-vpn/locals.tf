locals {
  internal_network_cidr           = cidrsubnet(var.internal_network_range, 3, 0)
  internal_network_vpn_server_ip  = cidrhost(local.internal_network_cidr, 3)
  wireguard_network_cidr          = cidrsubnet(var.internal_network_range, 3, 1)
  wireguard_network_vpn_server_ip = cidrhost(local.wireguard_network_cidr, 1)
  wireguard_remote_peers = [for i in range(var.vpn_remote_peers_count) : {
    name        = "peer-${i + 1}"
    ip_address  = cidrhost(local.wireguard_network_cidr, i + 2)
    public_key  = wireguard_asymmetric_key.remote[i].public_key
    private_key = wireguard_asymmetric_key.remote[i].private_key
  }]
  vpn_port_allowed_address_pairs = concat([for p in local.wireguard_remote_peers : p.ip_address], [local.wireguard_network_vpn_server_ip])
  wireguard_network_cidr_prefix  = split("/", local.wireguard_network_cidr)[1]

}
