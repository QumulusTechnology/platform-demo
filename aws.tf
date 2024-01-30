
# module "aws_network" {
#   source = "./network-with-vpn-aws"
#   count  = var.deploy_network_with_vpn_aws ? 1 : 0

#   internal_network_range = var.internal_network_range
#   public_ssh_key_path    = var.public_ssh_key_path
#   trusted_networks       = var.trusted_networks
#   public_network_name    = var.public_network_name
#   ssh_key_name           = var.ssh_key_name
#   aws_region             = var.aws_region
# }

# module "aws_ece" {
#   source = "./load-balanced-elastic-search-aws"
#   count  = local.deploy_ece_aws ? 1 : 0

#   vpc_id                = module.aws_network[0].vpc_id
#   private_network_cidrs = module.aws_network[0].private_network_cidrs
#   public_network_cidrs  = module.aws_network[0].public_network_cidrs
#   private_subnet_ids    = module.aws_network[0].private_subnet_ids
#   public_subnet_ids     = module.aws_network[0].public_subnet_ids
#   availability_zones    = module.aws_network[0].availability_zones
#   public_ssh_key_path   = var.public_ssh_key_path
#   private_ssh_key_path  = var.private_ssh_key_path
#   keypair_name          = module.aws_network[0].keypair_name
#   letsencrypt_email     = var.letsencrypt_email
#   ece_domain            = var.ece_domain
#   vpn_security_group_id = module.aws_network[0].vpn_security_group_id
#   run_ansible           = var.run_ansible
#   aws_region            = var.aws_region
#   depends_on            = [module.aws_network]

# }

# output "load_balancer_dns_aws" {
#   value = local.deploy_ece_aws ? module.aws_ece.load_balancer_dns : null
# }

# output "management_instance_connection_aws" {
#   value = local.deploy_ece_aws ? module.aws_ece.management_instance_connection : null
# }

# output "aws_hourly_costs" {
#   value = local.aws_hourly_costs
# }

# output "aws_monthly_costs" {
#   value = local.aws_monthly_costs
# }

# output "calculate_aws_costs" {
#   value = local.calculate_aws_costs
# }
