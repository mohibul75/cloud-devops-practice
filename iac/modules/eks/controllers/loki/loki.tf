resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = var.monitoring_namespace
  version    = var.loki_version

  values = [
    templatefile("${path.module}/templates/loki-values.yaml", {
      storage_class = var.storage_class
    })
  ]

  set {
    name  = "loki.persistence.enabled"
    value = "true"
  }

  set {
    name  = "loki.persistence.size"
    value = "2Gi"
  }

  set {
    name  = "promtail.enabled"
    value = "true"
  }

  set {
    name  = "promtail.config.lokiAddress"
    value = "http://loki:3100/loki/api/v1/push"
  }
}