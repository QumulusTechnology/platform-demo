
# module "aws_network" {
#   source = "./network-with-vpn-aws"

#   internal_network_range = var.internal_network_range
#   public_ssh_key_path    = var.public_ssh_key_path
#   trusted_networks       = var.trusted_networks
#   public_network_name    = var.public_network_name
#   ssh_key_name           = var.ssh_key_name
#   aws_region             = var.aws_region
# }

# module "aws_ece" {
#   source = "./load-balanced-elastic-search-aws"

#   vpc_id                = module.aws_network.vpc_id
#   private_network_cidrs = module.aws_network.private_network_cidrs
#   public_network_cidrs  = module.aws_network.public_network_cidrs
#   private_subnet_ids    = module.aws_network.private_subnet_ids
#   public_subnet_ids     = module.aws_network.public_subnet_ids
#   availability_zones    = module.aws_network.availability_zones
#   public_ssh_key_path   = var.public_ssh_key_path
#   private_ssh_key_path  = var.private_ssh_key_path
#   keypair_name          = module.aws_network.keypair_name
#   lets_encrypt_email    = var.lets_encrypt_email
#   ece_domain            = var.ece_domain
#   vpn_security_group_id = module.aws_network.vpn_security_group_id
#   run_ansible           = var.run_ansible
#   aws_region            = var.aws_region
#   depends_on            = [module.aws_network]

# }

# output "load_balancer_dns" {
#   value = module.aws_ece.load_balancer_dns
# }

# output "management_instance_connection" {
#   value = module.aws_ece.management_instance_connection
# }

# output "aws_hourly_costs" {
#   value = local.aws_hourly_costs
# }

# output "aws_monthly_costs" {
#   value = local.aws_monthly_costs
# }

# output "calculate_aws_costs" {
#   value = <<EOT
# To calculate the AWS costs for this deployment, run the following command:
# `TF_VAR_calculate_aws_costs=true terraform apply -target=module.pricing[0] -auto-approve`

# Note: The aws costs do not include metred charges like egress, disk_iops etc or backup/snapshot costs
# EOT
# }
