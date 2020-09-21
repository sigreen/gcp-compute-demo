variable "region" {
  description = "GCP region, e.g. us-east1"
  default = "us-east1"
}
variable "machine_type" {
  description = "Specifies the GCP instance type."
  default     = "f1-micro"
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "prefix" {
  description = "Prefix"
}
variable "gcp_instance_name" {
  description = "GCP Instance Name"
  default = "app1-server"
}
variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-b (which must be in gcp_region)"
  default = "us-east1-b"
}

variable "gcp_project" {
  description = "GCP project name"
}
