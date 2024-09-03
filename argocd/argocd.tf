

resource "random_password" "argocd_password" {
  length  = 24
  special = false
}


resource "local_sensitive_file" "argocd_password" {
  file_permission = "0600"
  content         = random_password.argocd_password.result
  filename        = "${path.module}/../passwords/argocd-password.txt"
}


resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.5.0"
  create_namespace = true
  wait             = true
  values = [sensitive(templatefile("${path.module}/templates/argocd-values.yaml.tftpl", {
    domain            = var.domain
    letsencrypt_email = var.letsencrypt_email
    argocd_secret     = random_password.argocd_password.bcrypt_hash
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
