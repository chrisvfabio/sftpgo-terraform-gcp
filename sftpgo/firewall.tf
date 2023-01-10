resource "google_compute_firewall" "default" {
  name          = "fw-allow-health-check"
  direction     = "INGRESS"
  network       = "default"
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
}
