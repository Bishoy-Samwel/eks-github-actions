variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "bucket_name" {
  type        = string
  description = "Base name for the Terraform state bucket"
  default     = "myapp-tfstate"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
