resource "kubernetes_namespace" "vpa" {
  metadata {
    name = "vpa"
  }
}

resource "helm_release" "vpa" {
  name             = "vpa"
  repository       = "https://charts.fairwinds.com/stable"
  chart            = "vpa"
  namespace        = kubernetes_namespace.vpa.metadata[0].name
  create_namespace = false
  version          = "1.7.2"  

  values = [
    file("${path.module}/templates/vpa-custom-values.yaml")
  ]

  depends_on = [kubernetes_namespace.vpa]
}