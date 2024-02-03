data "external" "get_secrets" {
  program = ["bash", "${path.module}/scripts/get-secrets.sh"]
  depends_on = [
    local_sensitive_file.argocd_password,
    local_sensitive_file.loki_password,
    local_sensitive_file.mimir_password
  ]
}
