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

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.storage_class
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "5Gi"
  }

  # Enable service monitors
  set {
    name  = "serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # Configure retention
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "2d"
  }

  # Configure Grafana
  set {
    name  = "grafana.enabled"
    value = "false"  # We're using our own Grafana installation
  }

  # Configure AlertManager
  set {
    name  = "alertmanager.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.persistence.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.persistence.storageClass"
    value = var.storage_class
  }

  set {
    name  = "alertmanager.persistence.size"
    value = "5Gi"
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}