output "load_balancer_dns" {
  value = local.deploy_ece ? module.ece.load_balancer_dns : null
}

output "management_instance_connection" {
  value = local.deploy_ece ? module.ece.management_instance_connection : null
}

