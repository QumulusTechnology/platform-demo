resource "openstack_containerinfra_cluster_v1" "public" {
  name                = "kubernetes-${var.kube_tag}-public"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.public.id
  master_count        = var.master_count
  node_count          = var.node_count
  merge_labels        = true
  labels = {
    "max_node_count" = var.max_node_count
    "min_node_count" = var.min_node_count
  }
}
