output "hashicups_url" {
  value = "http://${google_compute_instance.hashicups.network_interface.0.access_config.0.nat_ip}"
  sensitive = true
}

output "private_ip" {
  value = google_compute_instance.hashicups.network_interface.0.network_ip
  sensitive = true
}

output "priv-key"{
  value = tls_private_key.ssh-key.private_key_pem
  sensitive = true
}

output "network"{
  sensitive = true
  }

output "subnets"{
  sensitive = true
  }
