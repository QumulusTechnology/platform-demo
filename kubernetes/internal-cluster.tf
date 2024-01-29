resource "openstack_containerinfra_cluster_v1" "internal" {
  name                = "kubernetes-${var.kube_tag}-internal"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.internal.id
  master_count        = var.master_count
  node_count          = var.node_count
  merge_labels        = true
  labels = {
    "max_node_count" = var.max_node_count
    "min_node_count" = var.min_node_count
  }
}

### Adds any clusters available in the tenant to the kubeconfig file
resource "null_resource" "update_kube_config_internal" {

  count = var.update_kube_config ? 1 : 0

  triggers = {
    id = openstack_containerinfra_cluster_v1.internal.id
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/update-kubeconfig-from-openstack.sh"
  }

  depends_on = [
    openstack_containerinfra_cluster_v1.internal
  ]
}
