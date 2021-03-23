provider "google" {
  version = "~> 2.0"  
  project = var.gcp_project
  region  = var.region
}

resource "google_compute_network" "hashicups" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hashicups" {
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.hashicups.self_link
  ip_cidr_range = var.subnet_prefix
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-ssh-http"
  network = google_compute_network.hashicups.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hashicups" {
  name         = "${var.prefix}-hashicups"
  zone         = "${var.region}-b"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hashicups.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  tags = ["http-server","hashicups"]

}

resource "null_resource" "configure-hashicups" {
  depends_on = [
    google_compute_instance.hashicups,
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo add-apt-repository universe",
      "sudo apt -y update",
      "sudo apt -y install docker.io",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.27.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo curl -O https://raw.githubusercontent.com/jelinn/gcp-compute-demo/master/files/deployApp.sh",
      "sudo chmod +x ./deployApp.sh",
      "sudo ./deployApp.sh"
   ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.hashicups.network_interface.0.access_config.0.nat_ip
    }
  }
}
