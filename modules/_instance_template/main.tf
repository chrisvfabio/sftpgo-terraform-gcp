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
    startup-script = <<-EOF
#! /bin/bash
echo "Updating APT"
sudo apt update

echo "Installing Postgresql"
sudo apt -y install postgresql
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "Configuring Postgresql"
sudo -i -u postgres psql -c "create user "sftpgo" with encrypted password '${random_password.psql_password.result}';"
sudo -i -u postgres psql -c "create database "sftpgo";"
sudo -i -u postgres psql -c "grant all privileges on database "sftpgo" to "sftpgo";"

echo "Installing sftpgo"
sudo add-apt-repository -y ppa:sftpgo/sftpgo
sudo apt update
sudo apt-get install sftpgo -y

echo "Configuring sftpgo"
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__DRIVER=postgresql" >> /etc/sftpgo/env.d/postgresql.env'
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__NAME=sftpgo" >> /etc/sftpgo/env.d/postgresql.env'
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__HOST=127.0.0.1" >> /etc/sftpgo/env.d/postgresql.env'
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__PORT=5432" >> /etc/sftpgo/env.d/postgresql.env'
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__USERNAME=sftpgo" >> /etc/sftpgo/env.d/postgresql.env'
sudo bash -c 'echo "SFTPGO_DATA_PROVIDER__PASSWORD=${random_password.psql_password.result}" >> /etc/sftpgo/env.d/postgresql.env'

sudo bash -c 'echo "SFTPGO_HTTPD__BINDINGS__0__PROXY_ALLOWED=130.211.0.0/22,35.191.0.0/16" >> /etc/sftpgo/env.d/config.env'
sudo bash -c 'echo "SFTPGO_HTTPD__BINDINGS__0__CLIENT_IP_PROXY_HEADER=X-Forwarded-For" >> /etc/sftpgo/env.d/config.env'
sudo bash -c 'echo "SFTPGO_HTTPD__BINDINGS__0__CLIENT_IP_HEADER_DEPTH=0" >> /etc/sftpgo/env.d/config.env'

echo "Initializing sftpgo"
sudo su - sftpgo -s /bin/bash -c 'sftpgo initprovider -c /etc/sftpgo'

echo "Updating sftpgo systemctl"
echo "[Unit]" >> /tmp/sftpgo.service-override.conf
echo "After=postgresql.service" >> /tmp/sftpgo.service-override.conf
sudo env SYSTEMD_EDITOR="cp /tmp/sftpgo.service-override.conf" systemctl edit sftpgo.service

echo "Restarting sftpgo"
sudo systemctl restart sftpgo
EOF
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

