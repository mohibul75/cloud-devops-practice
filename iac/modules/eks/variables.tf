variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster and worker nodes"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
}

variable "dockerhub_username" {
  description = "DockerHub username for registry authentication"
  type        = string
  sensitive   = true
}

variable "dockerhub_token" {
  description = "DockerHub token for registry authentication"
  type        = string
  sensitive   = true
}