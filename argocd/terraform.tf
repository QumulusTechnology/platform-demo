terraform {
  required_providers {
    helm = {
      source                = "hashicorp/helm"
      version               = ">= 2.12.1"
      configuration_aliases = [helm.internal]
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.2"
    }
  }
}
