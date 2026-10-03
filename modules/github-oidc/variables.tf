variable "name_prefix" {
  type        = string
  description = "Prefix for role names"
  default     = "myapp"
}

variable "repo" {
  type        = string
  description = "GitHub repository in org/repo form (e.g., org/repo)"
  default     = ""
}

variable "repo_subject" {
  type        = string
  description = "GitHub subject with immutable IDs (e.g., org@ID/repo@ID). If empty, falls back to repo."
  default     = ""
}

variable "create_oidc_provider" {
  type        = bool
  description = "Whether to create the GitHub OIDC provider"
  default     = true
}

variable "github_oidc_thumbprints" {
  type        = list(string)
  description = "Thumbprints for GitHub OIDC provider"
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of ECR repository (empty string if not yet created)"
  default     = ""
}

variable "infra_apply_managed_policies" {
  type        = list(string)
  description = "Managed policies to attach to infra-apply role"
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "state_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket holding the remote Terraform state. Required: without s3:GetObject on it, `terraform init` cannot read the backend and every plan fails at init. Empty disables the statements."
  default     = ""
}

variable "state_lock_table_arn" {
  type        = string
  description = "ARN of the DynamoDB table used for state locking. Empty disables the statements."
  default     = ""
}

variable "infra_plan_managed_policies" {
  type        = list(string)
  description = "Managed policies to attach to infra-plan role. `terraform plan` refreshes every resource in the configuration, so it needs read access across the whole account — EKS, EC2, IAM, Secrets Manager and more. AWS managed policies use wildcards (ec2:Describe*, iam:Get*, secretsmanager:Describe*, s3:Get*), so ReadOnlyAccess covers them. Do not replace this with a hand-written allowlist: the list of actions a plan needs grows with every resource type added to the config."
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

variable "break_glass_principals" {
  type        = list(string)
  description = "Principals allowed to assume break-glass role (empty uses account root with MFA)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
