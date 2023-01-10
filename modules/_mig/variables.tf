variable "name" {
  type = string
}

variable "zone" {
  type = string
}

variable "http_port" {
  type    = number
  default = 8080
}

variable "instance_template_id" {
  type = string
}

variable "base_instance_name" {
  type    = string
  default = "sftpgo"
}
