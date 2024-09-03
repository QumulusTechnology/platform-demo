output "public_cluster_kube_config" {
  value     =  var.deploy_public_kubernetes_cluster ?  openstack_containerinfra_cluster_v1.public[0].kubeconfig["raw_config"] : null
  sensitive = true
}

output "public_cluster_host" {
  value     = var.deploy_public_kubernetes_cluster ?   openstack_containerinfra_cluster_v1.public[0].kubeconfig["host"] : null
  sensitive = true
}

output "public_cluster_cluster_ca_certificate" {
  value     =  var.deploy_public_kubernetes_cluster ?  openstack_containerinfra_cluster_v1.public[0].kubeconfig["cluster_ca_certificate"] : null
  sensitive = true
}

output "public_cluster_client_key" {
  value     =  var.deploy_public_kubernetes_cluster ?  openstack_containerinfra_cluster_v1.public[0].kubeconfig["client_key"] : null
  sensitive = true
}

output "public_cluster_client_certificate" {
  value = var.deploy_public_kubernetes_cluster ?  openstack_containerinfra_cluster_v1.public[0].kubeconfig["client_certificate"] : null
}

output "internal_cluster_kube_config" {
  value     = var.deploy_internal_kubernetes_cluster ? openstack_containerinfra_cluster_v1.internal[0].kubeconfig["raw_config"] : null
  sensitive = true
}

output "internal_cluster_host" {
  value     = var.deploy_internal_kubernetes_cluster ? openstack_containerinfra_cluster_v1.internal[0].kubeconfig["host"] : null
  sensitive = true
}

output "internal_cluster_cluster_ca_certificate" {
  value     = var.deploy_internal_kubernetes_cluster ? openstack_containerinfra_cluster_v1.internal[0].kubeconfig["cluster_ca_certificate"] : null
  sensitive = true
}

output "internal_cluster_client_key" {
  value     = var.deploy_internal_kubernetes_cluster ? openstack_containerinfra_cluster_v1.internal[0].kubeconfig["client_key"] : null
  sensitive = true
}

output "internal_cluster_client_certificate" {
  value = var.deploy_internal_kubernetes_cluster ? openstack_containerinfra_cluster_v1.internal[0].kubeconfig["client_certificate"] : null
}
