variable "role_name" {
  type        = string
  description = "IAM role name for pod"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace"
  default     = "app"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name"
  default     = "app"
}

variable "create_association" {
  type        = bool
  description = "Create pod identity association"
  default     = true
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "Managed policies to attach"
  default     = []
}

variable "inline_policy_json" {
  type        = string
  description = "Inline policy JSON"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
