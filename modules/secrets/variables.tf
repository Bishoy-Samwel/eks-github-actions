variable "name_prefix" {
  type        = string
  description = "Prefix for secret names (e.g., dev/myapp)"
  default     = "dev/myapp"
}

variable "password_length" {
  type        = number
  description = "Password length"
  default     = 32
}

variable "password_special" {
  type        = bool
  description = "Include special characters in password"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
