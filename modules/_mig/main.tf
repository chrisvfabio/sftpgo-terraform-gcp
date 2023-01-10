
resource "google_compute_instance_group_manager" "default" {
  name = "${var.name}-mig"
  zone = var.zone

  named_port {
    name = "http"
    port = var.http_port
  }

  version {
    instance_template = var.instance_template_id
    name              = "primary"
  }

  base_instance_name = var.base_instance_name
  target_size        = 1
}
