resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = var.monitoring_namespace
  version    = var.grafana_version

  values = [
    templatefile("${path.module}/templates/grafana-values.yaml", {
      storage_class = var.storage_class
      admin_password = var.grafana_admin_password
    })
  ]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "5Gi"
  }

  # Prometheus Data Source
  set {
    name  = "datasources.datasources\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].name"
    value = "Prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].type"
    value = "prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].url"
    value = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].access"
    value = "proxy"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].isDefault"
    value = "true"
  }

  # Loki Data Source
  set {
    name  = "datasources.datasources\\.yaml.datasources[1].name"
    value = "Loki"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[1].type"
    value = "loki"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[1].url"
    value = "http://loki.${var.monitoring_namespace}.svc.cluster.local:3100"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[1].access"
    value = "proxy"
  }

  # Tempo Data Source
  set {
    name  = "datasources.datasources\\.yaml.datasources[2].name"
    value = "Tempo"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[2].type"
    value = "tempo"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[2].url"
    value = "http://tempo.${var.monitoring_namespace}.svc.cluster.local:3100"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[2].access"
    value = "proxy"
  }

  # Link Tempo with Loki
  set {
    name  = "datasources.datasources\\.yaml.datasources[2].jsonData.tracesToLogs.datasourceUid"
    value = "Loki"
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}