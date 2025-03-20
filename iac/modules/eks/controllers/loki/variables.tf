variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "loki_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "2.9.10"
}

variable "storage_class" {
  description = "Storage class to use for persistent volumes"
  type        = string
  default     = "gp3"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}