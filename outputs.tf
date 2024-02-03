output "load_balancer_dns" {
  value = local.deploy_ece ? module.ece[0].load_balancer_dns : null
}

output "management_instance_connection" {
  value = local.deploy_ece ? module.ece[0].management_instance_connection : null
}
