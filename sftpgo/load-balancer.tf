module "load-balancer" {
  source = "../modules/_http-load-balancer"
  name   = "sftpgo"

  domains = var.domains

  health_check_port = 8080
  health_check_path = "/healthz"

  backend_instance_group_name = module.mig.instance_group
  backend_instance_group_zone = "${var.region}-a"
}
