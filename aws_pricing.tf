module "pricing" {
  count   = var.calculate_aws_costs ? 1 : 0
  source  = "terraform-aws-modules/pricing/aws//modules/cost.modules.tf"
  version = "2.0.2"
  content = file("${path.module}/terraform.tfstate")
}
