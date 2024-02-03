resource "helm_release" "internal_grafana_agent" {
  count            = var.deploy_internal_cluster_helm_charts == true ? 1 : 0
  provider         = helm.internal
  name             = "grafana-agent"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "k8s-monitoring"
  namespace        = "grafana-agent"
  version          = "0.8.6"
  create_namespace = true
  wait             = true
  values = [sensitive(templatefile("${path.module}/templates/grafana-agent-values.yaml.tftpl", {
    domain         = var.domain
    mimir_password = random_password.mimir_password.result
    loki_password  = random_password.loki_password.result
    }))
  ]
}
