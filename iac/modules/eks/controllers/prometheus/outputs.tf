output "prometheus_endpoint" {
  description = "Prometheus service endpoint for Grafana data source"
  value       = "http://prometheus-kube-prometheus-prometheus.${var.monitoring_namespace}.svc.cluster.local:9090"
}