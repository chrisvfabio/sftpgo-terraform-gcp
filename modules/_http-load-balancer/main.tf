
resource "google_compute_global_address" "default" {
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_health_check" "default" {
  name               = "${var.name}-hc"
  check_interval_sec = 5
  healthy_threshold  = 2
  http_health_check {
    port               = var.health_check_port
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = var.health_check_path
  }
  timeout_sec         = 5
  unhealthy_threshold = 2
}

data "google_compute_instance_group" "default" {
  name = var.backend_instance_group_name
  zone = var.backend_instance_group_zone
}

resource "google_compute_backend_service" "default" {
  name                            = "${var.name}-backend-service"
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.default.id]
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  protocol                        = "HTTP"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    group           = data.google_compute_instance_group.default.self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_managed_ssl_certificate" "certificate" {
  name = "${var.name}-cert"

  managed {
    domains = var.domains
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-http"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name}-http"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.name}-https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  port_range            = "443"
}

resource "google_compute_target_https_proxy" "default" {
  name    = "${var.name}-https"
  url_map = google_compute_url_map.default.id

  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.id]
}
