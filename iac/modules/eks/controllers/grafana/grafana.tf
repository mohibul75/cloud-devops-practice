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
      namespace = var.monitoring_namespace
    })
  ]
}