# Create dev namespace
resource "kubernetes_namespace" "dev_namespace" {
  metadata {
    name = "dev"
    labels = {
      "namespace" = "dev"
      "istio-injection" = "enabled"
    }
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

# Create DB namespace
resource "kubernetes_namespace" "db_namespace" {
  metadata {
    name = "db"
    labels = {
      "namespace" = "db"
    }
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "namespace" = "monitoring"
    }
  }
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
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

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    kubernetes_namespace.dev_namespace
  ]
}
