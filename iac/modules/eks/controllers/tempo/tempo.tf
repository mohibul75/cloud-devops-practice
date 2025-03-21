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
}