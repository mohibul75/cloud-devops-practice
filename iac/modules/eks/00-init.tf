# Create dev namespace
resource "kubernetes_namespace" "dev_namespace" {
  metadata {
    name = "dev"
    labels = {
      "namespace" = "dev"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "namespace" = "monitoring"
    }
  }
}

# Create Docker registry secret
resource "kubernetes_secret" "docker_registry" {
  metadata {
    name      = "regcred"
    namespace = kubernetes_namespace.dev_namespace.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          username = var.dockerhub_username
          password = var.dockerhub_token
          auth     = base64encode("${var.dockerhub_username}:${var.dockerhub_token}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.dev_namespace]
}
