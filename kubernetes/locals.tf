locals {
  internal_network_cidr               = cidrsubnet(var.internal_network_range, 3, 0)
  internal_kubernetes_lb_network_cidr = cidrsubnet(var.internal_network_range, 3, 3)
  internal_kubernetes_network_cidr    = cidrsubnet(var.internal_network_range, 3, 4)
  public_kubernetes_network_cidr      = cidrsubnet(var.internal_network_range, 3, 5)
}
