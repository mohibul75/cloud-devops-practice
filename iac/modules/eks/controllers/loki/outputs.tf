output "loki_endpoint" {
  description = "Loki service endpoint for Grafana data source"
  value       = "http://loki-gateway.${var.monitoring_namespace}.svc.cluster.local"
}