variable "name" {
  default = "sysbench"
}

variable "ext_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "project" {}

variable "tag" {}
variable "region" {}
variable "zone" {}
variable "slave_zone" {}

variable "db_instance_type" {}
variable "db_user" {}
variable "db_pwd" {}
variable "db_disk_size" {}
variable "db_disk_type" {}

variable "instance_type" {}

provider "google" {
  credentials = file("../../constant.json")
  project     = var.project
  region      = var.region
}

resource "google_compute_network" "vpc" {
  name = "${var.name}${var.tag}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name = "${var.name}${var.tag}"
  network = google_compute_network.vpc.name
  ip_cidr_range = "192.168.0.0/24"
}

resource "google_compute_firewall" "allow-host" {
  name        = "${var.name}${var.tag}"
  network     = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22", "9022"]
  }
  source_ranges = [var.ext_ip]
  target_tags   = ["instance"]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}${var.tag}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.self_link
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "database_instance" {
  name             = "${var.name}${var.tag}"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = false
  settings {
    tier = var.db_instance_type
    disk_size = var.db_disk_size
    disk_type = var.db_disk_type
    edition = "ENTERPRISE"
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.vpc.id
    }

    location_preference {
      zone = var.zone
      secondary_zone = var.slave_zone
    }

    backup_configuration {
      point_in_time_recovery_enabled = "true"
      enabled = "true"
    }
  }

  depends_on = [google_service_networking_connection.default]
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.database_instance.name
  password = var.db_pwd
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.vpc.name
  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_address" "static_ip" {
  name = "${var.name}${var.tag}"
  address_type = "EXTERNAL"
  region = var.region
  network_tier = "STANDARD"
}

resource "google_compute_instance" "instance" {
  name         = "${var.name}${var.tag}"
  machine_type = var.instance_type
  tags         = ["instance"]
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "centos-7"
      size  = 20
    }
  }
  metadata = {
    ssh-keys = "sysbench:${file("../../../image/authorized_keys")}"
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
      nat_ip = google_compute_address.static_ip.address
      network_tier = "STANDARD"
    }
  }

  depends_on = [google_sql_user.user]
}

output "url" {
  value = google_sql_database_instance.database_instance.private_ip_address
}

output "host" {
  value = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
}

output "user" {
  value = "sysbench"
}

output "container" {
  value = false
}

output "db_port" {
  value = 5432
}

output "db_user" {
  value = var.db_user
}

output "db_pwd" {
  value = var.db_pwd
}