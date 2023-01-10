resource "random_password" "psql_password" {
  length  = 16
  special = true
}


resource "google_compute_instance_template" "default" {
  name = "${var.name}-template"

  machine_type   = var.machine_type
  region         = var.region
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "ubuntu-1804-lts"
    auto_delete  = true
    boot         = true
  }

  metadata = {
    startup-script = var.startup_script
  }

  network_interface {
    network = "default"

    access_config {}
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  tags = ["allow-health-check"]
}

