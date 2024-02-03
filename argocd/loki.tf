resource "random_password" "loki_password" {
  length  = 24
  special = false
}

resource "local_sensitive_file" "loki_password" {
  file_permission = "0600"
  content         = random_password.loki_password.result
  filename        = "${path.module}/../passwords/loki-password.txt"
}

resource "kubectl_manifest" "loki_ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: loki
name: loki
YAML
}

resource "kubernetes_secret" "loki_secret" {
  metadata {
    name      = "loki-secret"
    namespace = "loki"
  }
  data = {
    ".htpasswd" = data.external.get_secrets.result["loki_secret"]
  }
  type = "Opaque"
  depends_on = [
    kubectl_manifest.loki_ns
  ]
}
