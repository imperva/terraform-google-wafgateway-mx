terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a simple VM instance
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnet_name

    access_config {
      # Ephemeral public IP
    }
  }

  tags = ["http-server", "https-server"]
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "test-vm-instance"
}

variable "instance_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "vpc_network" {
  description = "VPC Network name"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "default"
}


# Outputs
output "instance_name" {
  description = "Name of the created instance"
  value       = google_compute_instance.vm_instance.name
}

output "instance_ip" {
  description = "Public IP address of the instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ip" {
  description = "Internal IP address of the instance"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}
