resource "openstack_networking_secgroup_v2" "load_balancer" {
  name = "internet access to load balancer"
  tags = [ "ece-load-balancer" ]
}

resource "openstack_networking_secgroup_rule_v2" "load_balancer_rules" {
  for_each          = local.ece_load_balancer_listener_ports
  description       = each.value.description
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.key
  port_range_max    = each.key
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.load_balancer.id
}

resource "openstack_networking_secgroup_v2" "management_instance" {
  name = "management instance"
}

resource "openstack_networking_secgroup_rule_v2" "management_instance_vpn_access" {
  description       = "allow vpn users access to management instance"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = var.vpn_security_group_id
  security_group_id = openstack_networking_secgroup_v2.management_instance.id
}

### Allow traffic from load balancer to management instance
resource "openstack_networking_secgroup_rule_v2" "management_instance_letencrypt_rules" {
  for_each          = { for key, val in var.ece_load_balancer_pool_ports : key => val if val.role == "letsencrypt" }
  description       = each.value.description
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.key
  port_range_max    = each.key
  remote_ip_prefix  = local.internal_network_cidr
  security_group_id = openstack_networking_secgroup_v2.management_instance.id
}

resource "openstack_networking_secgroup_v2" "ece_servers" {
  name = "ece servers"
}

resource "openstack_networking_secgroup_rule_v2" "ece_servers_from_vpn" {
  description       = "allow vpn users access to ece servers"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = var.vpn_security_group_id
  security_group_id = openstack_networking_secgroup_v2.ece_servers.id
}

resource "openstack_networking_secgroup_rule_v2" "ece_servers_from_management_instance" {
  description       = "allow management instance access to ece servers"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.management_instance.id
  security_group_id = openstack_networking_secgroup_v2.ece_servers.id
}

resource "openstack_networking_secgroup_rule_v2" "ece_servers_internal_traffic" {
  description       = "allow ece servers to communicate with each other"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.ece_servers.id
  security_group_id = openstack_networking_secgroup_v2.ece_servers.id
}

### Allow traffic from load balancer to ece servers
resource "openstack_networking_secgroup_rule_v2" "ece_servers" {
  for_each          = { for key, val in var.ece_load_balancer_pool_ports : key => val if contains(["director", "coordinator", "proxy", "allocator"], val.role) }
  description       = each.value.description
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.key
  port_range_max    = each.key
  security_group_id = openstack_networking_secgroup_v2.ece_servers.id
  remote_ip_prefix  = local.internal_network_cidr
}
