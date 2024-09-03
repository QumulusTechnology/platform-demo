output "z1_management_instance_connection" {
  value = local.deploy_ece ? module.ece[0].management_instance_connection : null
}

output "z2_argocd_information" {
  value = local.deploy_argocd ? module.argocd[0].argocd_information : null
}

output "z3_load_balancer_dns" {
  value = local.deploy_ece ? module.ece[0].load_balancer_dns : null
}

output "z4_kubernetes_dns" {
  value = local.deploy_argocd ? module.argocd[0].kubernetes_dns : null
}
