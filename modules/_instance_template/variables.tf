variable "name" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "f1-micro"
}

variable "region" {
  type = string
}

variable "service_account_email" {
  type = string
}
