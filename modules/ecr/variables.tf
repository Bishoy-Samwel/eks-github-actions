variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "myapp"
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  default     = "IMMUTABLE"
}

variable "encryption_type" {
  type        = string
  description = "Encryption type (AES256 or KMS)"
  default     = "AES256"
}

variable "scan_on_push" {
  type        = bool
  description = "Enable image scanning on push"
  default     = true
}

variable "create_lifecycle_policy" {
  type        = bool
  description = "Create lifecycle policy"
  default     = true
}

variable "untagged_expire_days" {
  type        = number
  description = "Days to expire untagged images"
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
