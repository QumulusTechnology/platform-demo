locals {
  aws_hourly_costs  = var.calculate_aws_costs ? "${"$"}${module.pricing[0].hourly}" : null
  aws_monthly_costs = var.calculate_aws_costs ? "${"$"}${module.pricing[0].monthly}" : null
}
