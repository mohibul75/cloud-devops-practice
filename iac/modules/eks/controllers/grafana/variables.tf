variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "grafana_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "8.10.4"
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

variable "tempo_endpoint" {
  description = "Tempo service endpoint for Grafana data source"
  type        = string
}

variable "prometheus_endpoint" {
  description = "Prometheus service endpoint for Grafana data source"
  type        = string
}

variable "loki_endpoint" {
  description = "Loki service endpoint for Grafana data source"
  type        = string
}