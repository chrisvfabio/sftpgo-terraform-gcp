variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "domains" {
  description = "List of custom domain names."
  type        = list(string)
  default     = []
}

variable "health_check_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "backend_instance_group_name" {
  type = string
}

variable "backend_instance_group_zone" {
  type = string
}
