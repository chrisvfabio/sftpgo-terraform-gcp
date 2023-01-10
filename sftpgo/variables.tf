variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "domains" {
  type = list(string)
}

variable "dns_managed_zone_name" {
  type = string
}