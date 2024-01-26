output "load_balancer_dns" {
  value = <<EOT
Please create the following DNS Records

TYPE: A
DOMAIN_NAME: ${var.ece_domain}
VALUE: ${openstack_networking_floatingip_v2.elastic_floating_ip.address}

TYPE: A
DOMAIN_NAME: *.${var.ece_domain}
VALUE: ${openstack_networking_floatingip_v2.elastic_floating_ip.address}

EOT
}

output "management_instance_connection" {
  value = <<EOT
You can connect to the ece management instance using the following command:

ssh -i ${var.private_ssh_key_path} ${var.ece_user}@${cidrhost(local.internal_network_cidr, 4)}

(You will need to be connected to the vpn to connect to the management instance)
EOT
}
