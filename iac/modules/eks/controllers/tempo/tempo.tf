resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = var.monitoring_namespace
  version    = var.tempo_version

  values = [
    templatefile("${path.module}/templates/tempo-values.yaml", {
      storage_class = var.storage_class
    })
  ]

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "5Gi"
  }

  set {
    name  = "persistence.storageClass"
    value = var.storage_class
  }

  # Enable service monitors for Prometheus
  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus
  ]
}

# Deploy Tempo-Query for searching traces
resource "helm_release" "tempo_query" {
  name       = "tempo-query"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-query"
  namespace  = var.monitoring_namespace
  version    = var.tempo_query_version

  set {
    name  = "tempo.endpoint"
    value = "http://tempo:3100"
  }

  depends_on = [
    helm_release.tempo
  ]
}