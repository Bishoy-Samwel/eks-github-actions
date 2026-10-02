variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "myapp"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Explicit AZs to use; empty uses az_count"
  default     = []
}

variable "az_count" {
  type        = number
  description = "Number of AZs to use when availability_zones is empty"
  default     = 2
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use one NAT gateway for all private subnets"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for subnet tagging"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
