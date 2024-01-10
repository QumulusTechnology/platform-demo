data "external" "read_openstack_rc" {
  program = ["bash", "${path.module}/scripts/read-openstack-rc.sh", var.path_to_openstack_rc]
}
