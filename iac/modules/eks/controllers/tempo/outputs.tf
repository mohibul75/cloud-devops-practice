output "tempo_endpoint" {
  description = "Tempo service endpoint for Grafana data source"
  value       = "http://tempo.${var.monitoring_namespace}.svc.cluster.local:3200"
}