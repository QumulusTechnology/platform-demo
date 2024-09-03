data "openstack_networking_network_v2" "public" {
  name = var.public_network_name
}

data "openstack_images_image_v2" "management_instance" {
  name        = var.management_instance_image
  most_recent = true
}

data "openstack_images_image_v2" "elastic" {
  name        = var.elastic_image
  most_recent = true
}

data "openstack_compute_flavor_v2" "management_instance" {
  name = "m1.small"
}

data "openstack_compute_flavor_v2" "elastic" {
  name = "m1.xlarge"
}

data "openstack_compute_flavor_v2" "elastic_primary" {
  name = "t1.xxxlarge"
}

data "local_file" "load_balancer_tls_cert" {
  filename = "${path.module}/load-balancer-cert.p12"
  depends_on = [
    null_resource.load_balancer_pkcs12
  ]
}

data "external" "env" {
  program = ["${path.module}/scripts/env.sh"]
}
