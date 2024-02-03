locals {
  vpc_cidr                        = var.internal_network_range
  availability_zones              = [for z in var.zones : "${var.aws_region}${z}"]
  public_network_cidrs            = [for i, z in local.availability_zones : cidrsubnet(var.internal_network_range, 3, i)]
  private_network_cidrs           = [for i, z in local.availability_zones : cidrsubnet(var.internal_network_range, 3, i + 4)]
  internal_network_vpn_server_ip  = cidrhost(local.public_network_cidrs[0], 10)
  wireguard_network_cidr          = cidrsubnet(var.internal_network_range, 3, 3)
  wireguard_network_vpn_server_ip = cidrhost(local.wireguard_network_cidr, 1)
  wireguard_remote_peers = [for i in range(var.vpn_remote_peers_count) : {
    name        = "peer-${i + 1}"
    ip_address  = cidrhost(local.wireguard_network_cidr, i + 2)
    public_key  = wireguard_asymmetric_key.remote[i].public_key
    private_key = wireguard_asymmetric_key.remote[i].private_key
  }]
  wireguard_network_cidr_prefix = split("/", local.wireguard_network_cidr)[1]
}
