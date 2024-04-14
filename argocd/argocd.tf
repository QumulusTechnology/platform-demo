

resource "random_password" "argocd_password" {
  length  = 24
  special = false
}

resource "random_password" "argocd_password_salt" {
  length = 8
}

resource "htpasswd_password" "argocd_password" {
  password = random_password.argocd_password.result
  salt     = random_password.argocd_password_salt.result
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.53.12"
  create_namespace = true
  wait             = true
  values = [sensitive(templatefile("${path.module}/templates/argocd-values.yaml.tftpl", {
    domain            = var.domain
    letsencrypt_email = var.letsencrypt_email
    argocd_secret     = ":${htpasswd_password.argocd_password.bcrypt}"
    }))
  ]
}

resource "kubectl_manifest" "core_services_project" {
  depends_on = [helm_release.argocd]

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: core-services
  namespace: argocd
spec:
  description: Core Service Prod project
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  destinations:
    - namespace: '*'
      server: '*'
  sourceRepos:
    - '*'
YAML
}

resource "kubectl_manifest" "core_services_app_of_apps" {
  depends_on = [helm_release.argocd, kubectl_manifest.core_services_project]

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: core-services
  namespace: argocd
spec:
  project: core-services
  source:
    path: chart
    repoURL: https://github.com/QumulusTechnology/argocd-demo.git # always put the .git extension here
    targetRevision: main
    helm:
      valuesObject:
        letsencrypt_email: ${var.letsencrypt_email}
        domain: ${var.domain}
  destination:
    server: https://kubernetes.default.svc
    namespace: 'argocd'
  syncPolicy:
    syncOptions:
      - CreateNamespace=false
    automated:
      prune: true
      selfHeal: true
YAML
}
