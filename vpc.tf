module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 2.5"

    project_id   = var.gcp_project
    network_name = "example-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.gcp_region
        }
    ]
