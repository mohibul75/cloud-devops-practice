variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "prometheus_version" {
  description = "Prometheus Helm chart version (kube-prometheus-stack)"
  type        = string
  default     = "45.7.1"
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