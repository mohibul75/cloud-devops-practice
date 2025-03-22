# Create namespace for Karpenter
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Data sources for Karpenter CRDs
data "http" "karpenter_node_pools_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
}

data "http" "karpenter_ec2nodeclasses_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
}

data "http" "karpenter_nodeclaims_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"
}

# Deploy Karpenter CRDs
resource "kubernetes_manifest" "karpenter_node_pools_crd" {
  manifest = yamldecode(data.http.karpenter_node_pools_crd.response_body)
  depends_on = [
    kubernetes_namespace.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_ec2nodeclasses_crd" {
  manifest = yamldecode(data.http.karpenter_ec2nodeclasses_crd.response_body)
  depends_on = [
    kubernetes_namespace.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_nodeclaims_crd" {
  manifest = yamldecode(data.http.karpenter_nodeclaims_crd.response_body)
  depends_on = [
    kubernetes_namespace.karpenter
  ]
}

# Add Karpenter version variable
variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "1.1.1"  # Update this to match your desired version
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the cluster"
  type        = string
}

variable "node_iam_role_arn" {
  description = "ARN of the node IAM role"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.32.0"

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = var.node_iam_role_arn
  }

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      cluster_name = var.cluster_name
      vpc_id       = var.vpc_id
    })
  ]
}

resource "kubectl_manifest" "ec2_node_class" {
  depends_on = [helm_release.karpenter]
  yaml_body = templatefile("${path.module}/templates/ec2nodeclass.yml", {
    cluster_name    = var.cluster_name
    node_role_name  = var.node_iam_role_arn
  })
}

resource "kubectl_manifest" "node_pool" {
  depends_on = [kubectl_manifest.ec2_node_class]
  yaml_body  = file("${path.module}/templates/nodepool.yml")
}

# Tag subnets for Karpenter auto-discovery
resource "aws_ec2_tag" "subnet_tags" {
  for_each    = toset(var.private_subnet_ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag security groups for Karpenter auto-discovery
resource "aws_ec2_tag" "security_group_tags" {
  for_each    = toset([var.vpc_id])
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Create SQS queue for Karpenter interruption handling
resource "aws_sqs_queue" "karpenter" {
  name = "karpenter-sqs"

  message_retention_seconds = 300
  sqs_managed_sse_enabled  = true
}

resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      }
    ]
  })
}