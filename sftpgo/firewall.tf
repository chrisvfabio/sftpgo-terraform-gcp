resource "google_compute_firewall" "allow-glb-health-check" {
  name          = "allow-glb-health-check"
  direction     = "INGRESS"
  network       = "default"
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
  allow {
    ports    = ["8080"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow-ftp" {
  name          = "allow-ftp"
  direction     = "INGRESS"
  network       = "default"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-health-check"]
  allow {
    ports    = ["2022"]
    protocol = "tcp"
  }
}
