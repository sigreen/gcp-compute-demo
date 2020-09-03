provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
}


resource "google_compute_instance" "default" {
  name         = var.gcp_instance_name 
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["owner", "jlinn"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

