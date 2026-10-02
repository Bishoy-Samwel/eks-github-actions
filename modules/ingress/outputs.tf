output "namespace" {
  value       = helm_release.nginx_ingress.namespace
  description = "Namespace"
}

output "status" {
  value       = helm_release.nginx_ingress.status
  description = "Status"
}
