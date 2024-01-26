
# module "aws_network" {
#   source = "./network-with-vpn-aws"

#   internal_network_range  = var.internal_network_range
#   public_ssh_key_path     = var.public_ssh_key_path
#   trusted_networks        = var.trusted_networks
#   public_network_name     = var.public_network_name
#   ssh_key_name            = var.ssh_key_name
#   aws_region              = var.aws_region
#   aws_availability_zone_1 = var.aws_availability_zone_1
#   aws_availability_zone_2 = var.aws_availability_zone_2
# }

# module "aws_ece" {
#   source                  = "./load-balanced-elastic-search-aws"
#   aws_availability_zone_1 = var.aws_availability_zone_1
#   aws_availability_zone_2 = var.aws_availability_zone_2
#   internal_network_range  = var.internal_network_range
#   public_ssh_key_path     = var.public_ssh_key_path
#   private_ssh_key_path    = var.private_ssh_key_path
#   keypair_name            = module.aws_network.keypair_name
#   lets_encrypt_email      = var.lets_encrypt_email
#   ece_domain              = var.ece_domain
#   vpc_id                  = module.aws_network.vpc_id
#   private_subnet_1_id     = module.aws_network.private_subnet_1_id
#   private_subnet_2_id     = module.aws_network.private_subnet_2_id
#   public_subnet_1_id      = module.aws_network.public_subnet_1_id
#   public_subnet_2_id      = module.aws_network.public_subnet_2_id
#   vpn_security_group_id   = module.aws_network.vpn_security_group_id
#   run_ansible             = var.run_ansible
#   aws_region              = var.aws_region
#   depends_on              = [module.aws_network]

# }

# module "pricing" {
#   source  = "terraform-aws-modules/pricing/aws//modules/cost.modules.tf"
#   version = "2.0.2"
#   content = file("${path.module}/terraform.tfstate")
# }

# output "load_balancer_dns" {
#   value = module.aws_ece.load_balancer_dns
# }

# output "management_instance_connection" {
#   value = module.aws_ece.management_instance_connection
# }
# output "aws_hourly_costs" {
#   description = "Hourly costs"
#   value       = "${"$"}${module.pricing.hourly}"
# }

# output "aws_monthly_costs" {
#   description = "Monthly costs"
#   value       = "${"$"}${module.pricing.monthly}"
# }
