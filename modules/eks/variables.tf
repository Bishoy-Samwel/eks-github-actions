variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "myapp"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "myapp-dev"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.32"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for cluster and nodes"
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private API endpoint"
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public API endpoint"
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Public access CIDRs (if public endpoint enabled)"
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  type        = list(string)
  description = "Control plane log types"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "instance_types" {
  type        = list(string)
  description = "Node instance types"
  default     = ["t3.medium"]
}

variable "disk_size" {
  type        = number
  description = "Node disk size in GB"
  default     = 20
}

variable "desired_size" {
  type        = number
  description = "Desired number of nodes"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of nodes"
  default     = 3
}

variable "min_size" {
  type        = number
  description = "Minimum number of nodes"
  default     = 1
}

variable "max_unavailable" {
  type        = number
  description = "Max unavailable during update"
  default     = 1
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}

variable "authentication_mode" {
  type        = string
  description = "EKS authentication mode (API or API_AND_CONFIG_MAP)"
  default     = "API"
}
