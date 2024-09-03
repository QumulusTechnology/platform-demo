terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "= 2.1.0"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "= 0.3.1"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "= 0.2.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.65.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "= 2.15.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "= 2.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.32.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "= 1.2.1"
    }
  }

}
