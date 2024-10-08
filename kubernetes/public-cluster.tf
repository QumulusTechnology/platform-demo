resource "openstack_containerinfra_cluster_v1" "public" {
  count = var.deploy_public_kubernetes_cluster ? 1 : 0
  name                = "kubernetes-${var.kube_tag}-public"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.public.id
  master_count        = var.master_count
  node_count          = 3

  merge_labels = true
  labels = {
    "max_node_count" = var.max_node_count
    "min_node_count" = var.min_node_count
  }

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

### Adds any clusters available in the tenant to the kubeconfig file
resource "null_resource" "update_kube_config_public" {

  count = var.update_kube_config ? var.deploy_public_kubernetes_cluster ? 1 : 0 : 0

  triggers = {
    id = openstack_containerinfra_cluster_v1.public[0].id
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/update-kubeconfig-from-openstack.sh"
  }

  depends_on = [
    openstack_containerinfra_cluster_v1.public
  ]
}
