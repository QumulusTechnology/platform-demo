module "network" {
  source = "./network-with-vpn"
  count  = var.deploy_network_with_vpn ? 1 : 0

  internal_network_range = var.internal_network_range
  public_ssh_key_path    = var.public_ssh_key_path
  trusted_networks       = var.trusted_networks
  public_network_name    = var.public_network_name
  ssh_key_name           = var.ssh_key_name
}

module "ece" {
  source = "./load-balanced-elastic-search"
  count  = local.deploy_ece ? 1 : 0

  internal_network_range = var.internal_network_range
  public_network_name    = var.public_network_name
  public_ssh_key_path    = var.public_ssh_key_path
  private_ssh_key_path   = var.private_ssh_key_path
  keypair_name           = module.network[0].keypair_name
  letsencrypt_email      = var.letsencrypt_email
  ece_domain             = var.ece_domain
  internal_network_id    = module.network[0].internal_network_id
  internal_subnet_id     = module.network[0].internal_subnet_id
  vpn_security_group_id  = module.network[0].vpn_security_group_id
  run_ansible            = var.run_ansible

  depends_on = [module.network]
}

module "kubernetes" {
  count  = local.deploy_kubernetes ? 1 : 0
  source = "./kubernetes"

  internal_network_range = var.internal_network_range
  public_network_name    = var.public_network_name
  keypair_name           = module.network[0].keypair_name
  internal_network_id    = module.network[0].internal_network_id
  internal_subnet_id     = module.network[0].internal_subnet_id
  vpn_security_group_id  = module.network[0].vpn_security_group_id
  public_router_id       = module.network[0].public_router_id
  update_kube_config     = var.update_kube_config

  depends_on = [module.network]
}

module "argocd" {
  count  = local.deploy_argocd ? 1 : 0
  source = "./argocd"

   providers = {
    helm.internal = helm.internal
  }

  domain            = var.domain
  letsencrypt_email = var.letsencrypt_email

  depends_on = [module.network]
}
