# provider "aws" {
#   region = var.aws_region
# }

# module "aws_network" {
#   source                 = "./network-with-vpn-aws"
#   internal_network_range = var.internal_network_range
#   public_ssh_key_path    = var.public_ssh_key_path
#   trusted_networks       = var.trusted_networks
#   public_network_name    = var.public_network_name
#   ssh_key_name           = var.ssh_key_name
#   aws_region             = var.aws_region
# }

# module "aws_ece" {
#   source = "./load-balanced-elastic-search-aws"


#   vpc_id                                   = module.aws_network.vpc_id
#   private_network_cidrs                    = module.aws_network.private_network_cidrs
#   public_network_cidrs                     = module.aws_network.public_network_cidrs
#   private_subnet_ids                       = module.aws_network.private_subnet_ids
#   public_subnet_ids                        = module.aws_network.public_subnet_ids
#   availability_zones                       = module.aws_network.availability_zones
#   public_ssh_key_path                      = var.public_ssh_key_path
#   private_ssh_key_path                     = var.private_ssh_key_path
#   keypair_name                             = module.aws_network.keypair_name
#   letsencrypt_email                        = var.letsencrypt_email
#   ece_domain                               = var.ece_domain
#   elastic_primary_flavor                   = var.aws_elastic_primary_flavor
#   elastic_flavor                           = var.aws_elastic_flavor
#   elastic_ebs_volume_type                  = var.aws_elastic_ebs_volume_type
#   elastic_ebs_provisioned_iops_root_volume = var.aws_elastic_ebs_provisioned_iops_root_volume
#   elastic_ebs_provisioned_iops_data_volume = var.aws_elastic_ebs_provisioned_iops_data_volume
#   vpn_security_group_id                    = module.aws_network.vpn_security_group_id
#   run_ansible                              = var.run_ansible
#   aws_region                               = var.aws_region
#   depends_on                               = [module.aws_network]

# }

# output "load_balancer_dns_aws" {
#   value = module.aws_ece.load_balancer_dns
# }

# output "management_instance_connection_aws" {
#   value = module.aws_ece.management_instance_connection
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
