module "network" {
  source = "./simple-network-with-vpn"

  internal_network_range = var.internal_network_range
  public_ssh_key_path    = var.public_ssh_key_path
  trusted_networks       = var.trusted_networks
  public_network_name    = var.public_network_name
  ssh_key_name           = var.ssh_key_name
}

module "ece" {
  source = "./load-balanced-elastic-search"

  internal_network_range     = var.internal_network_range
  public_network_name        = var.public_network_name
  path_to_openstack_rc       = var.path_to_openstack_rc
  public_ssh_key_path        = var.public_ssh_key_path
  private_ssh_key_path       = var.private_ssh_key_path
  keypair_name               = module.network.keypair_name
  lets_encrypt_email         = var.lets_encrypt_email
  ece_domain                 = var.ece_domain
  internal_network_id        = module.network.internal_network_id
  internal_subnet_id         = module.network.internal_subnet_id
  vpn_security_group_id      = module.network.vpn_security_group_id
  load_balancer_floating_ip  = var.load_balancer_floating_ip
  run_ansible                = true

  depends_on = [ module.network ]
}

module "kubernetes" {
  source                 = "./kubernetes"
  internal_network_range = var.internal_network_range
  public_network_name    = var.public_network_name
  keypair_name           = module.network.keypair_name
  internal_network_id    = module.network.internal_network_id
  internal_subnet_id     = module.network.internal_subnet_id
  vpn_security_group_id  = module.network.vpn_security_group_id
  public_router_id       = module.network.public_router_id

  depends_on = [ module.network ]
}
