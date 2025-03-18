# Create Istio namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

# Install Istio base
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  set {
    name  = "defaultRevision"
    value = "default"
  }

  depends_on = [
    kubernetes_namespace.istio_system
  ]
}

# Install Istio control plane (istiod)
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  values = [
    templatefile("${path.module}/templates/istiod-values.yaml", {})
  ]

  depends_on = [
    helm_release.istio_base
  ]
}

# Install Istio Ingress Gateway
resource "helm_release" "istio_ingress_gateway" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  values = [
    templatefile("${path.module}/templates/istio-ingress-values.yaml", {})
  ]

  depends_on = [
    helm_release.istiod
  ]
}

# # Create namespace for Istio addons (Kiali, etc.)
# resource "kubernetes_namespace" "istio_addons" {
#   metadata {
#     name = "istio-addons"
#     labels = {
#       "istio-injection" = "enabled"
#     }
#   }

#   depends_on = [
#     helm_release.istiod
#   ]
# }

# # Install Kiali
# resource "helm_release" "kiali" {
#   name       = "kiali"
#   repository = "https://kiali.org/helm-charts"
#   chart      = "kiali-server"
#   namespace  = kubernetes_namespace.istio_addons.metadata[0].name
#   version    = var.kiali_version

#   values = [
#     templatefile("${path.module}/templates/kiali-values.yaml", {
#       grafana_url = "http://grafana.${var.monitoring_namespace}.svc.cluster.local"
#       prometheus_url = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local"
#       tracing_url = "http://tempo.${var.monitoring_namespace}.svc.cluster.local:16686"
#     })
#   ]

#   depends_on = [
#     kubernetes_namespace.istio_addons,
#     helm_release.istio_ingress
#   ]
# }