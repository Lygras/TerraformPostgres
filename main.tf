# Configure the Google Cloud provider
provider "google" {
  credentials = file("<PATH_TO_SERVICE_ACCOUNT_JSON>")
  project     = "<PROJECT_ID>"
  region      = "<REGION>"
  zone        = "<ZONE>"
}

# Create a Google Compute Engine instance
resource "google_compute_instance" "instance" {
  name         = "my-instance"
  machine_type = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-20044-lts"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y postgresql
    systemctl enable postgresql
    systemctl start postgresql
  EOF

  tags = ["allow-postgres"]
}

# Allow incoming traffic to the Postgres port
resource "google_compute_firewall" "firewall" {
  name    = "allow-postgres"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [""]
  target_tags   = ["allow-postgres"]
}
