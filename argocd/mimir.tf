resource "random_password" "mimir_password" {
  length  = 24
  special = false
}

resource "local_sensitive_file" "mimir_password" {
  file_permission = "0600"
  content         = random_password.mimir_password.result
  filename        = "${path.module}/../passwords/mimir-password.txt"
}

resource "kubectl_manifest" "mimir_ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: mimir
name: mimir
YAML
}

resource "kubernetes_secret" "mimir_secret" {
  metadata {
    name      = "mimir-secret"
    namespace = "mimir"
  }
  data = {
    ".htpasswd" = data.external.get_secrets.result["mimir_secret"]
  }
  type = "Opaque"
  depends_on = [
    kubectl_manifest.mimir_ns
  ]
}


resource "kubernetes_secret" "mimir_credentials" {
  metadata {
    name      = "mimir-credentials"
    namespace = "mimir"
  }
  data = {
    "mimir_host"     = "https://mimir.${var.domain}"
    "mimir_password" = random_password.mimir_password.result
    "mimir_username" = "admin"
    "loki_host"      = "https://loki.${var.domain}"
    "loki_password"  = random_password.loki_password.result
    "loki_username"  = "admin"
  }
  type = "Opaque"
  depends_on = [
    kubectl_manifest.mimir_ns
  ]
}
