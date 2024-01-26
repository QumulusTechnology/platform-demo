resource "openstack_compute_keypair_v2" "this" {
  name       = var.ssh_key_name
  public_key = file(var.public_ssh_key_path)
}
