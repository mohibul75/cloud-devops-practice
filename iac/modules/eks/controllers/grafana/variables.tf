variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "grafana_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "9.5.1"
}

variable "storage_class" {
  description = "Storage class to use for persistent volumes"
  type        = string
  default     = "gp3"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}