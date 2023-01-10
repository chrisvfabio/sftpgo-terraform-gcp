resource "google_service_account" "default" {
  account_id   = "sftpgo"
  display_name = "Service Account"
}

resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

module "instance_template" {
  source                = "../modules/_instance_template"
  name                  = "sftpgo"
  machine_type          = "f1-micro"
  region                = var.region
  service_account_email = google_service_account.default.email
}

module "mig" {
  source               = "../modules/_mig"
  name                 = "sftpgo"
  zone                 = "${var.region}-a"
  http_port            = 8080
  instance_template_id = module.instance_template.instance_template_id
  base_instance_name   = "sftpgo"
}
