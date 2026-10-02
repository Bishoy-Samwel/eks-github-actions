output "role_arn" {
  value       = aws_iam_role.pod.arn
  description = "Pod IAM role ARN"
}

output "role_name" {
  value       = aws_iam_role.pod.name
  description = "Pod IAM role name"
}

output "association_id" {
  value       = var.create_association ? aws_eks_pod_identity_association.pod[0].association_id : null
  description = "Pod identity association ID"
}
