variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "grafana_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "6.50.7"  # You can update this to the latest version
}

variable "loki_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "2.9.10"
}

variable "prometheus_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "45.7.1"  # kube-prometheus-stack version
}

variable "tempo_version" {
  description = "Tempo Helm chart version"
  type        = string
  default     = "1.3.1"
}

variable "tempo_query_version" {
  description = "Tempo Query Helm chart version"
  type        = string
  default     = "1.3.1"
}

variable "istio_version" {
  description = "Istio Helm chart version"
  type        = string
  default     = "1.18.2"
}

variable "kiali_version" {
  description = "Kiali Helm chart version"
  type        = string
  default     = "1.73.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
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