variable "addons" {
  type = list(object({
    name    = string
    version = optional(string)
  }))

  default = [
    {
      name    = "kube-proxy"
    },
    {
      name    = "vpc-cni"
    },
    {
      name    = "coredns"
    },
    {
      name    = "aws-ebs-csi-driver"
    },
    {
      name    = "aws-efs-csi-driver"
    }
  ]
}

resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.main.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

module "istio" {
  source = "./controllers/istio"
  cluster_name = aws_eks_cluster.main.id
  istio_version = "1.25.0"
  kiali_version = "1.40.0"
}

data "http" "metric_server" {
  url = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
}

locals {
  metrics_server_manifests = split("---", data.http.metric_server.response_body)
}

resource "kubernetes_manifest" "metric_server" {
  for_each = { for idx, manifest in compact(local.metrics_server_manifests) : idx => manifest if manifest != "" }
  manifest = yamldecode(each.value)
  depends_on = [
    kubernetes_namespace.monitoring
  ]
}