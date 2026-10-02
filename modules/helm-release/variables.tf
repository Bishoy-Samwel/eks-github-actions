variable "name" {
  type        = string
  description = "Release name"
}

variable "repository" {
  type        = string
  description = "Chart repository URL"
}

variable "chart" {
  type        = string
  description = "Chart name"
}

variable "chart_version" {
  type        = string
  description = "Chart version"
}

variable "namespace" {
  type        = string
  description = "Namespace"
  default     = "default"
}

variable "create_namespace" {
  type        = bool
  description = "Create namespace"
  default     = true
}

variable "values" {
  type        = list(string)
  description = "Values files/inline"
  default     = []
}

variable "wait" {
  type        = bool
  description = "Wait for deployment"
  default     = true
}

variable "timeout" {
  type        = number
  description = "Timeout in seconds"
  default     = 300
}

variable "lint" {
  type        = bool
  description = "Lint chart"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
