output "oidc_provider_arn" {
  value       = module.github_oidc.oidc_provider_arn
  description = "ARN of GitHub OIDC provider"
}

output "ci_ecr_push_role_arn" {
  value       = module.github_oidc.ci_ecr_push_role_arn
  description = "ARN of CI ECR push role"
}

output "infra_plan_role_arn" {
  value       = module.github_oidc.infra_plan_role_arn
  description = "ARN of infra plan role"
}

output "infra_apply_role_arn" {
  value       = module.github_oidc.infra_apply_role_arn
  description = "ARN of infra apply role"
}

output "break_glass_role_arn" {
  value       = module.github_oidc.break_glass_role_arn
  description = "ARN of break-glass role"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "ecr_repository_arn" {
  value       = module.ecr.repository_arn
  description = "ECR repository ARN"
}

output "db_secret_arn" {
  value       = module.secrets.db_secret_arn
  description = "DB secret ARN"
}

output "redis_secret_arn" {
  value       = module.secrets.redis_secret_arn
  description = "Redis secret ARN"
}

output "pod_identity_app_role_arn" {
  value       = module.pod_identity_app.role_arn
  description = "Pod identity app role ARN"
}
