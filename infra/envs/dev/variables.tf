variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "myapp"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in org/repo form"
  default     = ""
}

variable "github_repo_subject" {
  type        = string
  description = "GitHub subject with immutable IDs (org@ID/repo@ID)"
  default     = ""
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider"
  default     = true
}

variable "ecr_repository_arn" {
  type        = string
  description = "ECR repository ARN if it exists"
  default     = ""
}

variable "infra_apply_managed_policies" {
  type        = list(string)
  description = "Managed policies for infra apply role"
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "myapp-dev"
}

variable "argocd_chart_version" {
  type        = string
  description = "Argo CD chart version"
  default     = "5.51.6"
}

variable "external_secrets_chart_version" {
  type        = string
  description = "External Secrets chart version"
  default     = "0.9.13"
}

variable "argocd_image_updater_chart_version" {
  type        = string
  description = "Argo CD Image Updater chart version"
  default     = "0.9.4"
}
