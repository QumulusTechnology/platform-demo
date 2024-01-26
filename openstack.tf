module "network" {
  source = "./network-with-vpn"

  internal_network_range = var.internal_network_range
  public_ssh_key_path    = var.public_ssh_key_path
  trusted_networks       = var.trusted_networks
  public_network_name    = var.public_network_name
  ssh_key_name           = var.ssh_key_name
}

module "ece" {
  source = "./load-balanced-elastic-search"

  internal_network_range = var.internal_network_range
  public_network_name    = var.public_network_name
  public_ssh_key_path    = var.public_ssh_key_path
  private_ssh_key_path   = var.private_ssh_key_path
  keypair_name           = module.network.keypair_name
  lets_encrypt_email     = var.lets_encrypt_email
  ece_domain             = var.ece_domain
  internal_network_id    = module.network.internal_network_id
  internal_subnet_id     = module.network.internal_subnet_id
  vpn_security_group_id  = module.network.vpn_security_group_id
  run_ansible            = var.run_ansible

  depends_on = [module.network]
}

output "load_balancer_dns" {
  value = module.ece.load_balancer_dns
}

output "management_instance_connection" {
  value = module.ece.management_instance_connection
}


# module "kubernetes" {
#   source                 = "./kubernetes"
#   internal_network_range = var.internal_network_range
#   public_network_name    = var.public_network_name
#   keypair_name           = module.network.keypair_name
#   internal_network_id    = module.network.internal_network_id
#   internal_subnet_id     = module.network.internal_subnet_id
#   vpn_security_group_id  = module.network.vpn_security_group_id
#   public_router_id       = module.network.public_router_id
#   update_kube_config     = var.update_kube_config
#   depends_on             = [module.network]
# }
