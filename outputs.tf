output "load_balancer_dns" {
  value = local.deploy_ece ? module.ece[0].load_balancer_dns : null
}

output "management_instance_connection" {
  value = local.deploy_ece ? module.ece[0].management_instance_connection : null
}


output "argocd_host" {
  value = local.deploy_argocd ? module.argocd[0].argocd_host : null
}

output "argocd_username" {
  value = local.deploy_argocd ? module.argocd[0].argocd_username : null
}

output "argocd_password" {
  value     = local.deploy_argocd ? module.argocd[0].argocd_password : null
  sensitive = true
}

output "mimir_host" {
  value = local.deploy_argocd ? module.argocd[0].mimir_host : null
}

output "mimir_username" {
  value = local.deploy_argocd ? module.argocd[0].mimir_username : null
}

output "mimir_password" {
  value     = local.deploy_argocd ? module.argocd[0].mimir_password : null
  sensitive = true
}

output "mimir_tenant" {
  value = local.deploy_argocd ? module.argocd[0].mimir_tenant : null
}

output "loki_host" {
  value = local.deploy_argocd ? module.argocd[0].loki_host : null
}

output "loki_username" {
  value = local.deploy_argocd ? module.argocd[0].loki_username : null
}

output "loki_password" {
  value     = local.deploy_argocd ? module.argocd[0].loki_password : null
  sensitive = true
}

output "loki_tenant" {
  value = local.deploy_argocd ? module.argocd[0].loki_tenant : null
}
