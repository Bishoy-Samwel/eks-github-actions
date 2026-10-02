output "oidc_provider_arn" {
  value       = local.oidc_provider_arn
  description = "ARN of the GitHub OIDC provider"
}

output "ci_ecr_push_role_arn" {
  value       = aws_iam_role.ci_ecr_push.arn
  description = "ARN of the CI ECR push role"
}

output "infra_plan_role_arn" {
  value       = aws_iam_role.infra_plan.arn
  description = "ARN of the infra plan role"
}

output "infra_apply_role_arn" {
  value       = aws_iam_role.infra_apply.arn
  description = "ARN of the infra apply role"
}

output "break_glass_role_arn" {
  value       = aws_iam_role.break_glass.arn
  description = "ARN of the break-glass role"
}
