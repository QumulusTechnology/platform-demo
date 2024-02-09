resource "helm_release" "internal_grafana_agent" {
  name             = "grafana-agent"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "k8s-monitoring"
  namespace        = "grafana-agent"
  version          = "0.8.6"
  create_namespace = true
  wait             = true
  values = [sensitive(templatefile("${path.module}/templates/grafana-agent-values.yaml.tftpl", {
    mimir_host     = var.mimir_host
    mimir_username = var.mimir_username
    mimir_password = var.mimir_password
    mimir_tenant   = var.mimir_tenant
    loki_host      = var.loki_host
    loki_username  = var.loki_username
    loki_password  = var.loki_password
    loki_tenant    = var.loki_tenant
    }))
  ]
}
