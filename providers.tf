

provider "openstack" {
  max_retries = 1
}

# provider "aws" {
#   region                      = var.aws_region
#   skip_credentials_validation = true
#   skip_region_validation      = true
#   skip_requesting_account_id  = true
#   skip_metadata_api_check     = true
# }


provider "helm" {
  kubernetes {
    host                   = local.public_cluster_host
    client_certificate     = local.public_cluster_client_certificate
    client_key             = local.public_cluster_client_key
    cluster_ca_certificate = local.public_cluster_cluster_ca_certificate
  }
}

provider "helm" {
  alias = "internal"
  kubernetes {
    host                   = local.internal_cluster_host
    client_certificate     = local.internal_cluster_client_certificate
    client_key             = local.internal_cluster_client_key
    cluster_ca_certificate = local.internal_cluster_cluster_ca_certificate
  }
}

provider "kubectl" {
  host                   = local.public_cluster_host
  client_certificate     = local.public_cluster_client_certificate
  client_key             = local.public_cluster_client_key
  cluster_ca_certificate = local.public_cluster_cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host                   = local.public_cluster_host
  client_certificate     = local.public_cluster_client_certificate
  client_key             = local.public_cluster_client_key
  cluster_ca_certificate = local.public_cluster_cluster_ca_certificate

}
