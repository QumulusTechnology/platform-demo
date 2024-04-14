locals {
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

  terraform_tf_state = fileexists("${path.module}/terraform.tfstate") ? file("${path.module}/terraform.tfstate") : "{}"

  calculate_aws_costs = fileexists("${path.module}/terraform.tfstate")
}
