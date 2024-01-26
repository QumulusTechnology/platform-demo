output "internal_network_id" {
    value = openstack_networking_network_v2.internal.id
}

output "internal_subnet_id" {
    value = openstack_networking_subnet_v2.internal.id
}

output "vpn_security_group_id" {
    value = openstack_networking_secgroup_v2.vpn_server.id
}

output "public_router_id" {
    value = openstack_networking_router_v2.public.id
}

output "keypair_name" {
    value = openstack_compute_keypair_v2.this.name
}
