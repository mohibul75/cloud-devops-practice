variable "istio_version" {
  description = "Istio Helm chart version"
  type        = string
  default     = "1.25.0"
}

variable "kiali_version" {
  description = "Kiali Helm chart version"
  type        = string
  default     = "1.40.0"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}