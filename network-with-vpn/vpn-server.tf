
# This is the firewall group that allows SSH and WireGuard traffic to the VPN server
resource "openstack_networking_secgroup_v2" "vpn_server" {
  name = "vpn-server"
}

resource "openstack_networking_secgroup_rule_v2" "wireguard_protocol" {
  count             = length(var.trusted_networks)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 51820
  port_range_max    = 51820
  remote_ip_prefix  = var.trusted_networks[count.index]
  security_group_id = openstack_networking_secgroup_v2.vpn_server.id
}

# These are the WireGuard keys and preshared key that will be used to configure the VPN server
resource "wireguard_asymmetric_key" "default" {
}

resource "wireguard_asymmetric_key" "remote" {
  count = var.vpn_remote_peers_count
}

resource "wireguard_preshared_key" "this" {
}

# This is the network port that will be used to connect the VPN server.
# Note that the allowed_address_pairs allow the VPN server to route traffic from the remote peer.
# An alternative option would be to disable port security or to configure NAT within the VPN server.
resource "openstack_networking_port_v2" "vpn_server_port" {
  name       = "vpn-server-port"
  network_id = openstack_networking_network_v2.internal.id

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal.id
    ip_address = local.internal_network_vpn_server_ip
  }

  security_group_ids = [openstack_networking_secgroup_v2.vpn_server.id]

  allowed_address_pairs {
    ip_address = local.wireguard_network_cidr
  }

  depends_on = [
    openstack_networking_subnet_v2.internal
  ]
}

# This is the VPN server instance
resource "openstack_compute_instance_v2" "vpn_server" {
  name      = "vpn-server"
  image_id  = data.openstack_images_image_v2.vpn.id
  flavor_id = data.openstack_compute_flavor_v2.vpn.id
  key_pair  = openstack_compute_keypair_v2.this.name
  user_data = templatefile("${path.module}/templates/vpn-server-cloud-init.tftpl", {
    wireguard_interface_ip        = local.wireguard_network_vpn_server_ip,
    wireguard_network_cidr_prefix = local.wireguard_network_cidr_prefix,
    remote_peers                  = local.wireguard_remote_peers,
    default_private_key           = wireguard_asymmetric_key.default.private_key,
    default_public_key            = wireguard_asymmetric_key.default.public_key,
    wireguard_preshared_key       = wireguard_preshared_key.this.key,
  })
  network {
    port = openstack_networking_port_v2.vpn_server_port.id
  }
}

# This is the public IP address that will be used to connect to the VPN server
resource "openstack_networking_floatingip_v2" "vpn_server_public_ip" {
  pool = data.openstack_networking_network_v2.public.name
}


resource "openstack_networking_floatingip_associate_v2" "vpn_server_public_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.vpn_server_public_ip.address
  port_id     = openstack_networking_port_v2.vpn_server_port.id
}

# This is the route that tells OpenStack to route traffic to the VPN server for the WireGuard network
resource "openstack_networking_router_route_v2" "vpn_server_route" {
  router_id        = openstack_networking_router_v2.public.id
  destination_cidr = local.wireguard_network_cidr
  next_hop         = local.internal_network_vpn_server_ip
  depends_on = [
    openstack_networking_router_interface_v2.router_internal_interface
  ]
}

output "vpn_server_public_ip" {
  value = openstack_networking_floatingip_v2.vpn_server_public_ip.address
}

# This is the WireGuard configuration file that will be used to configure the remote peers
resource "local_sensitive_file" "wireguard_config" {
  count           = length(local.wireguard_remote_peers)
  file_permission = "0600"
  content = templatefile("${path.module}/../network-with-vpn/templates/wireguard-conf.tftpl", {
    vpn_server_public_ip          = openstack_networking_floatingip_v2.vpn_server_public_ip.address,
    remote_peer_ip                = local.wireguard_remote_peers[count.index].ip_address,
    internal_network_range        = var.internal_network_range,
    wireguard_network_cidr_prefix = local.wireguard_network_cidr_prefix,
    default_public_key            = wireguard_asymmetric_key.default.public_key,
    remote_peer_private_key       = local.wireguard_remote_peers[count.index].private_key,
    wireguard_preshared_key       = wireguard_preshared_key.this.key,
  })

  filename = "${path.module}/../wireguard-${local.wireguard_remote_peers[count.index].name}.conf"
}
