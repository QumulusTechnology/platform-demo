resource "openstack_containerinfra_clustertemplate_v1" "internal" {
  name                  = "kubernetes-${var.kube_tag}-internal"
  image                 = var.kube_image_name
  coe                   = "kubernetes"
  flavor                = var.node_flavor
  master_flavor         = var.master_flavor
  docker_storage_driver = "overlay2"
  docker_volume_size    = var.docker_volume_size
  volume_driver         = "cinder"
  network_driver        = "calico"
  server_type           = "vm"
  master_lb_enabled     = false
  floating_ip_enabled   = false
  keypair_id            = data.openstack_compute_keypair_v2.this.id
  external_network_id   = var.internal_network_id
  fixed_network         = openstack_networking_network_v2.internal_kubernetes.id
  fixed_subnet          = openstack_networking_subnet_v2.internal_kubernetes.id
  labels = {
    kube_tag                                = var.kube_tag
    auto_scaling_enabled                    = true
    auto_healing_enabled                    = true
    auto_healing_controller                 = "magnum-auto-healer"
    ingress_controller                      = "octavia"
    min_node_count                          = 3
    max_node_count                          = 1
  }
}

resource "openstack_containerinfra_clustertemplate_v1" "public" {
  name                  = "kubernetes-${var.kube_tag}-public"
  image                 = var.kube_image_name
  coe                   = "kubernetes"
  flavor                = var.node_flavor
  master_flavor         = var.master_flavor
  docker_storage_driver = "overlay2"
  docker_volume_size    = var.docker_volume_size
  volume_driver         = "cinder"
  network_driver        = "calico"
  server_type           = "vm"
  master_lb_enabled     = true
  floating_ip_enabled   = false
  keypair_id            = data.openstack_compute_keypair_v2.this.id
  external_network_id   = data.openstack_networking_network_v2.public.id
  fixed_network         = openstack_networking_network_v2.public_kubernetes.id
  fixed_subnet          = openstack_networking_subnet_v2.public_kubernetes.id
  labels = {
    kube_tag                                = var.kube_tag
    auto_scaling_enabled                    = true
    auto_healing_enabled                    = true
    auto_healing_controller                 = "magnum-auto-healer"
    ingress_controller                      = "octavia"
    min_node_count                          = var.min_node_count
    max_node_count                          = var.max_node_count
  }
}
