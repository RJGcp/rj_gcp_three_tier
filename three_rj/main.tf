terraform {
  
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 5
}

locals {
    network_name = "${var.network_name}-safer-${random_id.suffix.hex}"
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
}

module "lb" {
  source = "../modules/network-load-balancer"

  name    = var.name
  region  = var.region
  project = var.project_id

  enable_health_check = true
  health_check_port   = "5000"
  health_check_path   = "/api"

  firewall_target_tags = [var.name]

  instances = [google_compute_instance.api.self_link]

  custom_labels = var.custom_labels
}

resource "google_compute_instance" "api" {
  project      = var.project_id
  name         = "${var.name}-gce"
  machine_type = "f1-micro"
  zone         = var.zone

 
  tags = [
    var.name,
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
 
  metadata_startup_script = file("${path.module}/startup-script.sh")

  network_interface {
    network = module.network-safer-mysql-simple.network_name

    # Assign public ip
    access_config {}
  }


}

resource "google_compute_firewall" "firewall" {
  project = var.project_id
  name    = "${var.name}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
 
  source_ranges = ["0.0.0.0/0"]
  
  target_tags = [var.name]
}
module "network-safer-mysql-simple" {
  source  = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = local.network_name

  subnets = []
}

module "private-service-access" {
  source      = "../modules/private_service_access"
  project_id  = var.project_id
  vpc_network = module.network-safer-mysql-simple.network_name
}

module "safer-mysql-db" {
  source               = "../modules/safer_mysql"
  name                 = var.db_name
  random_instance_name = true
  project_id           = var.project_id

  deletion_protection = false

  database_version = "MYSQL_5_6"
  region           = "var.region"
  zone             = "var.region"
  tier             = "db-n1-standard-1"
  assign_public_ip = "true"
  vpc_network      = module.network-safer-mysql-simple.network_self_link

  module_depends_on = [module.private-service-access.peering_completed]
}