variable "namespace" {
  type        = string
  description = "Namespace for ingress controller"
  default     = "ingress-nginx"
}

variable "nginx_ingress_version" {
  type        = string
  description = "NGINX Ingress Controller chart version"
  default     = "4.9.1"
}

variable "values" {
  type        = list(string)
  description = "Values for helm release"
  default     = []
}

variable "timeout" {
  type        = number
  description = "Timeout in seconds"
  default     = 600
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
