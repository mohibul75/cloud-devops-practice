variable "addons" {
  type = list(object({
    name                    = string
    version                 = optional(string)
    service_account_role_arn = optional(string)
    configuration_values    = optional(string)
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
      name    = "aws-efs-csi-driver"
    }
  ]
}

# Create IAM role for EBS CSI Driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create IAM role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi" {
  name = "ebs-csi-controller-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Name        = "ebs-csi-controller"
  }
}

# Attach EBS CSI policy to role
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = data.aws_iam_policy.ebs_csi_policy.arn
  role       = aws_iam_role.ebs_csi.name
}

locals {
  all_addons = concat(var.addons, [
    {
      name = "aws-ebs-csi-driver"
      version = "v1.25.0-eksbuild.1"
      service_account_role_arn = aws_iam_role.ebs_csi.arn
      configuration_values = jsonencode({
        controller = {
          serviceAccount = {
            create = true
            name   = "ebs-csi-controller-sa"
          }
        }
      })
    }
  ])
}

resource "aws_eks_addon" "addons" {
  for_each          = { for addon in local.all_addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.main.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  service_account_role_arn = each.value.service_account_role_arn
  configuration_values = each.value.configuration_values
  resolve_conflicts_on_update = "PRESERVE"
  
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}

module "istio" {
  source = "./controllers/istio"
  cluster_name = aws_eks_cluster.main.id
  istio_version = "1.25.0"
  kiali_version = "1.40.0"

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    kubernetes_namespace.monitoring,
    aws_eks_addon.addons
  ]
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
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    kubernetes_namespace.monitoring,
    aws_eks_addon.addons
  ]
}