output "name" {
  value       = helm_release.this.name
  description = "Release name"
}

output "namespace" {
  value       = helm_release.this.namespace
  description = "Namespace"
}

output "status" {
  value       = helm_release.this.status
  description = "Release status"
}
