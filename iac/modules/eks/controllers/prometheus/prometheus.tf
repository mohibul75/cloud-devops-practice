resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.monitoring_namespace
  version    = var.prometheus_version

  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml", {
      storage_class = var.storage_class
    })
  ]
}