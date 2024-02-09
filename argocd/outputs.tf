output "mimir_host" {
    value = "https://mimir.${var.domain}"
}

output "mimir_username" {
    value = "admin"
}

output "mimir_password" {
    value = random_password.mimir_password.result
}

output "mimir_tenant" {
    value = "master"
}

output "loki_host" {
    value = "https://gateway-loki.${var.domain}"
}

output "loki_username" {
    value = "admin"
}

output "loki_password" {
    value = random_password.loki_password.result
}

output "loki_tenant" {
    value = "master"
}

