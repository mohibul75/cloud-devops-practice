resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana/loki"
  version    = var.loki_chart_version
  namespace  = var.monitoring_namespace

  values = [
    templatefile("${path.module}/templates/loki-values.yaml", {
      storage_class = var.storage_class
    })
  ]

}

resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana/promtail"
  version    = var.promtail_chart_version
  namespace  = var.monitoring_namespace

  values = [
    templatefile("${path.module}/templates/promtail.yaml", {
      loki_address = "http://loki:3100/loki/api/v1/push"
    })
  ]

  depends_on = [
    helm_release.loki
  ]
}
