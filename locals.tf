locals {
  aws_hourly_costs  = var.calculate_aws_costs ? "${"$"}${module.pricing[0].total_price_per_hour}" : null
  aws_monthly_costs = var.calculate_aws_costs ? "${"$"}${module.pricing[0].total_price_per_month}" : null
  deploy_ece        = var.deploy_network_with_vpn && var.deploy_ece
  deploy_kubernetes = var.deploy_network_with_vpn && var.deploy_kubernetes
  deploy_argocd     = var.deploy_kubernetes && var.deploy_argocd

  public_cluster_host                     = local.deploy_argocd == false ? null : module.kubernetes[0].public_cluster_host
  public_cluster_client_certificate       = local.deploy_argocd == false ? null : module.kubernetes[0].public_cluster_client_certificate
  public_cluster_client_key               = local.deploy_argocd == false ? null : module.kubernetes[0].public_cluster_client_key
  public_cluster_cluster_ca_certificate   = local.deploy_argocd == false ? null : module.kubernetes[0].public_cluster_cluster_ca_certificate
  internal_cluster_host                   = local.deploy_argocd == false ? null : module.kubernetes[0].internal_cluster_host
  internal_cluster_client_certificate     = local.deploy_argocd == false ? null : module.kubernetes[0].internal_cluster_client_certificate
  internal_cluster_client_key             = local.deploy_argocd == false ? null : module.kubernetes[0].internal_cluster_client_key
  internal_cluster_cluster_ca_certificate = local.deploy_argocd == false ? null : module.kubernetes[0].internal_cluster_cluster_ca_certificate

  calculate_aws_costs_message = <<EOT
To calculate the AWS costs for this deployment, run the following command:
`TF_VAR_calculate_aws_costs=true terraform apply -target=module.pricing[0] -auto-approve`

Note: The aws costs do not include metred charges like egress, disk_iops etc or backup/snapshot costs
EOT
  calculate_aws_costs         = var.calculate_aws_costs ? null : local.calculate_aws_costs_message
}
