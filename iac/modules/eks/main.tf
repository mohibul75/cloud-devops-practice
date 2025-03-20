locals {
  name = "${var.project}-${var.environment}"
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${local.name}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# EKS Node IAM Role
resource "aws_iam_role" "node" {
  name = "${local.name}-Worker-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_policy" "autoscaler" {
  name = "eks-autoscaler-${var.environment}-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
    policy_arn = aws_iam_policy.autoscaler.arn
    role       = aws_iam_role.node.name
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name        = "CloudWatchFullAccess-${var.environment}"
  description = "Provides full access to Amazon CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:*",
          "logs:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
    policy_arn = aws_iam_policy.cloudwatch_full_access.arn
    role       = aws_iam_role.node.name
}

# Create instance profile for worker nodes
resource "aws_iam_instance_profile" "worker_nodes" {
  name = "${local.name}-Worker-Profile"
  role = aws_iam_role.node.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = local.name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = flatten([var.public_subnet_ids[*], var.private_subnet_ids[*]])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]

  tags = var.tags
}

# Create OIDC Provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# EKS Node Groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.public_subnet_ids

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20


  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = merge(
    {
      "Name" = "${local.name}-${each.key}",
      "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "owned",
      "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" = "owned",
      "eks:cluster-name" = aws_eks_cluster.main.name,
      "aws:eks:cluster-name" = aws_eks_cluster.main.name
    },
    var.tags
  )
}
