output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "Cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Cluster API endpoint"
}

output "cluster_version" {
  value       = aws_eks_cluster.main.version
  description = "Kubernetes version"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "CA cert data"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "Cluster SG ID"
}

output "cluster_arn" {
  value       = aws_eks_cluster.main.arn
  description = "Cluster ARN"
}

output "node_group_arn" {
  value       = aws_eks_node_group.main.arn
  description = "Node group ARN"
}

output "node_group_status" {
  value       = aws_eks_node_group.main.status
  description = "Node group status"
}

output "cluster_oidc_issuer_url" {
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
  description = "OIDC issuer URL for the cluster"
}

output "pod_identity_agent_addon_id" {
  value       = aws_eks_addon.pod_identity_agent.id
  description = "Pod Identity Agent addon ID"
}
