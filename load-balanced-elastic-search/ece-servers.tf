resource "openstack_networking_port_v2" "elastic" {
  for_each  = local.ece_servers
  name      = each.value.name
  network_id = var.internal_network_id
  fixed_ip {
    subnet_id  = var.internal_subnet_id
    ip_address = each.value.ip_address
  }
  security_group_ids = [openstack_networking_secgroup_v2.ece_servers.id]
}

resource "openstack_compute_instance_v2" "elastic" {
  for_each  = local.ece_servers
  name      = each.value.name
  image_id  = data.openstack_images_image_v2.elastic.id
  flavor_id = each.key == "0" ? data.openstack_compute_flavor_v2.elastic_primary.id : data.openstack_compute_flavor_v2.elastic.id
  key_pair  = var.keypair_name
  network {
    port = openstack_networking_port_v2.elastic[each.key].id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.elastic.id
    source_type           = "image"
    volume_size           = 40
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 400
    boot_index            = 1
    delete_on_termination = true
  }

}
