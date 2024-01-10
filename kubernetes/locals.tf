locals {
  internal_network_cidr = cidrsubnet(var.internal_network_range, 2, 0)
  internal_kubernetes_network_cidr = cidrsubnet(var.internal_network_range, 2, 2)
  public_kubernetes_network_cidr = cidrsubnet(var.internal_network_range, 2, 3)
}
