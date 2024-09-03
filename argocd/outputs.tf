output "argocd_host" {
  value = "https://argocd.${var.domain}"
}

output "argocd_username" {
  value = "admin"
}

output "argocd_password" {
  value = random_password.argocd_password.result
}

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

output "grafana_host" {
  value = "https://grafana.${var.domain}"
}

output "grafana_username" {
  value = "admin"
}

output "grafana_password" {
  value = random_password.grafana_password.result
}

output "argocd_information" {
  value = <<EOT

ArgoCD Deployment:

ArgoCD has been successfully deployed and is accessible at the following URL: https://argocd.${var.domain}.

Login Details:
  Username: admin
  Password: Refer to passwords/argocd-password.txt for the password.

Within ArgoCD, the following applications have been deployed:

- Mimir
- Loki
- Grafana
- Ingress NGINX
- Cert-Manager

Grafana Deployment:

Grafana has been successfully deployed and is accessible at the following URL: https://grafana.${var.domain}.

Login Details:
  Username: admin
  Password: Refer to passwords/grafana-password.txt for the password.

The Grafana deploypment includes a series of dashboards designed to monitor the Kubernetes cluster and the applications deployed within it.
  EOT
}

output "kubernetes_dns" {
  value = <<EOT

Please fetch the Public IP Address of the Ingress Controller Load Balancer uing the following command:

  kubectl -n ingress-nginx get service ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'

And then create the following DNS Records:

TYPE: A
DOMAIN_NAME: nginx.${var.domain}
VALUE: {ingress-nginx-controller-public-ip}

TYPE: CNAME
DOMAIN_NAME: argocd.${var.domain}
VALUE: nginx.${var.domain}

TYPE: CNAME
DOMAIN_NAME: grafana.${var.domain}
VALUE: nginx.${var.domain}

TYPE: CNAME
DOMAIN_NAME: mimir.${var.domain}
VALUE: nginx.${var.domain}

TYPE: CNAME
DOMAIN_NAME: gateway-loki.${var.domain}
VALUE: nginx.${var.domain}

It will take a few minutes for the DNS records to propagate and cert-manager to issue the LetsEncrypt certificates.

You cam check the progress of the certificate signing request for argocd using the following commaind

  k -n argocd describe certificaterequests.cert-manager.io argocd-cert-1
EOT
}
