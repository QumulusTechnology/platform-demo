output "public_cluster_kube_config" {
  value     = openstack_containerinfra_cluster_v1.public.kubeconfig["raw_config"]
  sensitive = true
}

output "public_cluster_host" {
  value     = openstack_containerinfra_cluster_v1.public.kubeconfig["host"]
  sensitive = true
}

output "public_cluster_cluster_ca_certificate" {
  value     = openstack_containerinfra_cluster_v1.public.kubeconfig["cluster_ca_certificate"]
  sensitive = true
}

output "public_cluster_client_key" {
  value     = openstack_containerinfra_cluster_v1.public.kubeconfig["client_key"]
  sensitive = true
}

output "public_cluster_client_certificate" {
  value = openstack_containerinfra_cluster_v1.public.kubeconfig["client_certificate"]
}

output "internal_cluster_kube_config" {
  value     = openstack_containerinfra_cluster_v1.internal.kubeconfig["raw_config"]
  sensitive = true
}

output "internal_cluster_host" {
  value     = openstack_containerinfra_cluster_v1.internal.kubeconfig["host"]
  sensitive = true
}

output "internal_cluster_cluster_ca_certificate" {
  value     = openstack_containerinfra_cluster_v1.internal.kubeconfig["cluster_ca_certificate"]
  sensitive = true
}

output "internal_cluster_client_key" {
  value     = openstack_containerinfra_cluster_v1.internal.kubeconfig["client_key"]
  sensitive = true
}

output "internal_cluster_client_certificate" {
  value = openstack_containerinfra_cluster_v1.internal.kubeconfig["client_certificate"]
}
